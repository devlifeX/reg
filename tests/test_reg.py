"""Regression tests. Every shell, installer and write uses a temporary home."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RegTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="reg-tests-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "checkout with spaces"
        shutil.copytree(ROOT, self.repo, ignore=shutil.ignore_patterns(".git", "tests", "__pycache__"))
        self.home = self.root / "home with spaces"
        self.home.mkdir()
        self.bashrc = self.home / ".bashrc"
        self.bashrc.write_text("")
        self.store = self.repo / "storage/reg.cmd"
        self.store.write_text("")
        self.env = {**os.environ, "HOME": str(self.home), "REG_TEST_REPO": str(self.repo)}
        for name in ("BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS"):
            self.env.pop(name, None)

    def shell(self, script, status=0):
        result = subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", 'source "$REG_TEST_REPO/reg.sh" || exit $?\n' + script],
            cwd=self.root, env=self.env, capture_output=True, timeout=10,
        )
        # Avoid text mode normalizing carriage returns in command round-trip tests.
        result.stdout = result.stdout.decode()
        result.stderr = result.stderr.decode()
        if status is not None:
            self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result

    def install(self, env=None, status=0):
        result = subprocess.run(
            ["bash", str(self.repo / "installer.sh")], cwd=self.root,
            env=env or self.env, text=True, capture_output=True, timeout=10,
        )
        self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result

    def test_source_from_other_directory(self):
        self.assertIn("Reg 1.0.1", self.shell("reg -v").stdout)

    def test_repeated_execution_does_not_accumulate(self):
        result = self.shell('''reg add first 'echo FIRST' >/dev/null
reg add second 'echo SECOND' >/dev/null
reg first
reg second
reg second''')
        self.assertEqual(result.stdout, "FIRST\nSECOND\nSECOND\n")

    def test_failure_stops_steps_and_does_not_poison_next_group(self):
        result = self.shell('''reg add failed 'false' 'echo WRONG' >/dev/null
reg add next 'echo NEXT' >/dev/null
reg failed
printf 'status=%s\\n' "$?"
reg next''')
        self.assertEqual(result.stdout, "status=1\nNEXT\n")

    def test_skip_and_take_are_one_based_and_keep_original_order(self):
        result = self.shell('''reg add steps 'echo ONE' 'echo TWO' 'echo THREE' >/dev/null
reg steps -s 2,3
reg steps -t 03,01,01
reg steps -s 1,2,3''')
        self.assertEqual(result.stdout, "ONE\nONE\nTHREE\n")

    def test_invalid_indices_execute_nothing(self):
        for value in ("", "0", "4", "1,,2", "1,", "-1", "x", "9999999999999999999999999999"):
            with self.subTest(value=value):
                self.store.write_text("")
                result = self.shell('''reg add steps 'echo WRONG' 'echo WRONG' 'echo WRONG' >/dev/null
reg steps -s "$BAD_INDEX"'''.replace('"$BAD_INDEX"', "'" + value + "'"), status=1)
                self.assertNotIn("WRONG", result.stdout)

    def test_invalid_arguments_and_reserved_names_do_not_write(self):
        for command in ("reg add", "reg add name", "reg add name ''", "reg add add 'echo BAD'",
                        "reg add 'bad;name' 'echo BAD'", "reg remove", "reg unknown",
                        "reg env BAD-NAME value", "reg alias bad", "reg list absent"):
            with self.subTest(command=command):
                self.shell(command, status=1)
                self.assertEqual(self.store.read_text(), "")
                self.assertEqual(self.bashrc.read_text(), "")

    def test_numeric_legacy_names_still_work(self):
        self.store.write_text("123; echo OLD\n")
        self.assertEqual(self.shell("reg 123").stdout, "OLD\n")

    def test_source_does_not_override_user_print_function(self):
        result = self.shell('print() { printf USER; }; source "$REG_TEST_REPO/reg.sh"; print')
        self.assertEqual(result.stdout, "USER")

    def test_readonly_env_does_not_change_bashrc(self):
        self.bashrc.write_text("# KEEP\n")
        for command in ("reg env LOCKED new", "reg env -d LOCKED"):
            self.shell("readonly LOCKED=old; " + command, status=1)
            self.assertEqual(self.bashrc.read_text(), "# KEEP\n")

    def test_duplicate_does_not_overwrite(self):
        self.shell("reg add name 'echo ORIGINAL' >/dev/null")
        before = self.store.read_bytes()
        self.shell("reg add name 'echo WRONG'", status=1)
        self.assertEqual(self.store.read_bytes(), before)

    def test_commands_preserve_quotes_spaces_semicolons_and_backslashes(self):
        result = self.shell(r'''reg add text 'printf "%s\n" "a  b; c" "literal\n" "*"' >/dev/null
reg text''')
        self.assertEqual(result.stdout, "a  b; c\nliteral\\n\n*\n")

    def test_multiline_command_and_trailing_newline_round_trip(self):
        result = self.shell(r'''text=$'printf "ONE\\n"\nprintf "TWO\\n"\n'
reg add multiline "$text" >/dev/null
reg list multiline
printf '%s\n' MARKER
reg multiline''')
        self.assertEqual(result.stdout, 'printf "ONE\\n"\nprintf "TWO\\n"\n\nMARKER\nONE\nTWO\n')

    def test_record_encoding_round_trips_special_characters(self):
        values = [
            "printf '%s' 'tab\tand\rcarriage'",
            r"printf '%s' '\c\073\012\\'",
            "printf '%s' 'سلام; دنیا'",
            "# comment\necho NEXT\n\n",
        ]
        for value in values:
            with self.subTest(value=value):
                self.store.write_text("")
                self.env["REG_TEST_COMMAND"] = value
                result = self.shell('reg add text "$REG_TEST_COMMAND" >/dev/null; reg list text')
                self.assertEqual(result.stdout, value + "\n")

    def test_shell_options_are_preserved(self):
        result = self.shell('''set -eu
before=$-
source "$REG_TEST_REPO/reg.sh"
reg add steps 'true' >/dev/null
reg steps
[[ $- == "$before" ]]''')
        self.assertEqual(result.stderr, "")

    def test_glob_expands_at_execution_not_registration(self):
        result = self.shell('''mkdir glob-dir
cd glob-dir
reg add files 'printf "%s\\n" *' >/dev/null
printf '' > later-file
reg files''')
        self.assertEqual(result.stdout, "later-file\n")

    def test_listing_does_not_execute_command_and_numbers_steps(self):
        result = self.shell('''reg add steps 'touch SHOULD_NOT_EXIST' 'echo SECOND' >/dev/null
reg list steps -num
reg list''')
        self.assertEqual(result.stdout, "1: touch SHOULD_NOT_EXIST\n2: echo SECOND\nsteps; touch SHOULD_NOT_EXIST; echo SECOND\n")
        self.assertFalse((self.root / "SHOULD_NOT_EXIST").exists())

    def test_remove_is_literal_and_accepts_paths_in_commands(self):
        self.shell('''reg add foo.bar 'echo /tmp/demo' >/dev/null
reg add fooXbar 'echo /tmp/demo' >/dev/null
reg remove foo.bar >/dev/null''')
        self.assertEqual(self.shell("reg fooXbar").stdout, "/tmp/demo\n")
        self.shell("reg foo.bar", status=1)

    def test_legacy_records_can_execute_list_and_remove(self):
        self.store.write_text("legacy; echo OLD; echo TWO\nfoo.bar; echo /tmp/demo\nfooXbar; echo /tmp/demo")
        result = self.shell('''reg legacy -t 2
reg list legacy -num
reg remove foo.bar >/dev/null
reg add new 'echo NEW' >/dev/null
reg new''')
        self.assertEqual(result.stdout, "TWO\n1:  echo OLD\n2:  echo TWO\nNEW\n")
        self.assertIn("fooXbar; echo /tmp/demo", self.store.read_text())
        self.assertNotIn("foo.bar;", self.store.read_text())

    def test_functions_do_not_overwrite_common_shell_variables(self):
        result = self.shell('''counter=99; message=KEEP; cmd=KEEP; output=KEEP; args=KEEP
reg add hello 'true' >/dev/null
reg hello
reg list hello >/dev/null
reg remove hello >/dev/null
printf '%s|%s|%s|%s|%s\\n' "$counter" "$message" "$cmd" "$output" "$args"''')
        self.assertEqual(result.stdout, "99|KEEP|KEEP|KEEP|KEEP\n")

    def test_command_runs_in_current_shell(self):
        result = self.shell('''reg add move 'cd "$REG_TEST_REPO"' >/dev/null
reg move
[[ $PWD == "$REG_TEST_REPO" ]]''')
        self.assertEqual(result.stderr, "")

    def test_alias_and_env_persist_without_restarting_shell(self):
        result = self.shell(r'''keep=YES
reg env GREETING 'hello world; $(touch BAD)' >/dev/null
reg env EMPTY '' >/dev/null
reg alias greeting 'printf "%s\n" "hello world"' >/dev/null
printf '%s|%s|%s\n' "$GREETING" "$EMPTY" "$keep"
alias greeting
bash --noprofile --norc -c 'source "$HOME/.bashrc"; printf "%s|%s\n" "$GREETING" "$EMPTY"; alias greeting' ''')
        self.assertEqual(result.stdout, "hello world; $(touch BAD)||YES\nalias greeting='printf \"%s\\n\" \"hello world\"'\nhello world; $(touch BAD)|\nalias greeting='printf \"%s\\n\" \"hello world\"'\n")
        self.assertFalse((self.root / "BAD").exists())
        self.assertEqual(result.stderr, "")

    def test_env_name_does_not_collide_with_internal_local_variables(self):
        self.assertEqual(self.shell("reg env reg_record VALUE >/dev/null; printf '%s' \"$reg_record\"").stdout, "VALUE")

    def test_alias_and_env_update_replace_existing_definitions(self):
        self.shell('''reg env VALUE old >/dev/null
reg env VALUE new >/dev/null
reg alias name 'echo old' >/dev/null
reg alias name 'echo new' >/dev/null''')
        content = self.bashrc.read_text()
        self.assertEqual(content.count("export VALUE="), 1)
        self.assertEqual(content.count("alias name="), 1)
        self.assertNotIn("old", content)

    def test_alias_and_env_removal_leave_other_lines_and_current_shell_intact(self):
        self.bashrc.write_text('alias fooXbar="echo KEEP"\nexport FOOXBAR=keep\n# alias foo.bar=comment\n')
        result = self.shell('''reg alias foo.bar 'echo REMOVE' >/dev/null
reg env FOO REMOVE >/dev/null
reg alias -d foo.bar >/dev/null
reg env -d FOO >/dev/null
[[ -z ${FOO+x} ]]
! alias foo.bar 2>/dev/null''')
        self.assertEqual(result.stderr, "")
        self.assertEqual(self.bashrc.read_text(), 'alias fooXbar="echo KEEP"\nexport FOOXBAR=keep\n# alias foo.bar=comment\n')

    def test_write_failure_reports_failure_without_success_message(self):
        result = self.shell('REG_FILE_NAME="$HOME/missing/reg.cmd"; reg add name "echo BAD"', status=1)
        self.assertNotIn("saved", result.stdout)

    def test_failed_atomic_replace_preserves_original_and_cleans_temp_file(self):
        self.shell("reg add original 'echo KEEP' >/dev/null")
        before = self.store.read_bytes()
        result = self.shell('mv() { return 1; }; reg remove original', status=1)
        self.assertEqual(self.store.read_bytes(), before)
        self.assertEqual(list(self.store.parent.glob("reg.cmd.*")), [])
        self.assertNotIn("removed", result.stdout)

    def test_bashrc_symlink_is_preserved(self):
        target = self.home / "actual bashrc"
        target.write_text("# KEEP\n")
        self.bashrc.unlink()
        self.bashrc.symlink_to(target.name)
        self.shell("reg env TEST value >/dev/null")
        self.assertTrue(self.bashrc.is_symlink())
        self.assertEqual(target.read_text(), "# KEEP\nexport TEST=value\n")

    def test_reload_does_not_replace_shell(self):
        self.bashrc.write_text("RELOADED=YES\n")
        result = self.shell('keep=YES; reg reload; printf "%s|%s" "$RELOADED" "$keep"')
        self.assertEqual(result.stdout, "YES|YES")

    def test_installer_preserves_data_permissions_and_startup_lines_on_upgrade(self):
        self.bashrc.write_text('# KEEP\nsource /usr/local/bin/reg/reg-master/reg.sh\n# source /usr/local/bin/reg/reg-master/reg.sh\nsource /usr/local/bin/reg/reg-master/reg.sh-other\n')
        self.install()
        installed = self.home / ".local/share/reg"
        store = installed / "storage/reg.cmd"
        store.write_text("legacy; echo KEPT\n")
        self.install()
        self.assertEqual(store.read_text(), "legacy; echo KEPT\n")
        content = self.bashrc.read_text()
        self.assertIn("# KEEP\n", content)
        self.assertIn("# source /usr/local/bin/reg/reg-master/reg.sh\n", content)
        self.assertIn("source /usr/local/bin/reg/reg-master/reg.sh-other\n", content)
        self.assertNotIn("\nsource /usr/local/bin/reg/reg-master/reg.sh\n", content)
        self.assertEqual(content.count(".local/share/reg/reg.sh"), 1)
        for path in [installed, *installed.rglob("*")]:
            self.assertEqual(path.stat().st_mode & 0o077, 0, str(path))
        result = self.shell('source "$HOME/.local/share/reg/reg.sh"; reg legacy')
        self.assertEqual(result.stdout, "KEPT\n")

    def test_failed_install_restores_previous_install(self):
        self.install()
        installed = self.home / ".local/share/reg"
        store = installed / "storage/reg.cmd"
        store.write_text("legacy; echo KEPT\n")
        before = (installed / "reg.sh").read_bytes()
        self.bashrc.unlink()
        self.bashrc.mkdir()  # Refuse a non-file .bashrc after promoting the new directory.
        self.install(status=1)
        self.assertEqual(store.read_text(), "legacy; echo KEPT\n")
        self.assertEqual((installed / "reg.sh").read_bytes(), before)
        self.assertEqual(list(installed.parent.glob("reg.*")), [])

    def test_failed_staging_preserves_existing_install_and_bashrc(self):
        self.install()
        installed = self.home / ".local/share/reg"
        store = installed / "storage/reg.cmd"
        store.write_text("legacy; echo KEPT\n")
        before = self.bashrc.read_bytes()
        (self.repo / "inc").rename(self.repo / "missing-inc")
        self.install(status=1)
        self.assertEqual(store.read_text(), "legacy; echo KEPT\n")
        self.assertEqual(self.bashrc.read_bytes(), before)
        self.assertEqual(list(installed.parent.glob("reg.*")), [])

    def test_failed_first_install_leaves_no_partial_install(self):
        (self.repo / "inc").rename(self.repo / "missing-inc")
        self.install(status=1)
        self.assertFalse((self.home / ".local/share/reg").exists())
        self.assertEqual(self.bashrc.read_text(), "")

    def test_missing_runtime_module_aborts_source_and_upgrade(self):
        self.install()
        before = self.bashrc.read_bytes()
        (self.repo / "inc/reg_exe.sh").unlink()
        self.shell("echo SHOULD_NOT_RUN", status=1)
        self.install(status=1)
        self.assertEqual(self.bashrc.read_bytes(), before)
        self.assertTrue((self.home / ".local/share/reg/inc/reg_exe.sh").is_file())

    def test_all_shell_files_parse(self):
        for path in [self.repo / "reg.sh", self.repo / "installer.sh", *sorted((self.repo / "inc").glob("*.sh"))]:
            result = subprocess.run(["bash", "-n", str(path)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
