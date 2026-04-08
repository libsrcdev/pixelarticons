import unittest
import re

# Dart keywords set — must match download.py
KEYWORDS = {
    'abstract', 'else', 'import', 'show', 'as', 'enum', 'in', 'static',
    'assert', 'export', 'interface', 'super', 'async', 'extends', 'is',
    'switch', 'await', 'extension', 'late', 'sync', 'break', 'external',
    'library', 'this', 'case', 'factory', 'mixin', 'throw', 'catch', 'false',
    'new', 'true', 'class', 'final', 'null', 'try', 'const', 'finally', 'on',
    'typedef', 'continue', 'for', 'operator', 'var', 'covariant', 'Function',
    'part', 'void', 'default', 'get', 'required', 'while', 'deferred', 'hide',
    'rethrow', 'with', 'do', 'if', 'return', 'yield', 'dynamic', 'implements',
    'set'
}


def needs_prefix(filename: str) -> bool:
    """Replicates the renaming logic from download.py.
    Returns True if the file should be prefixed with 'k'."""
    from pathlib import Path
    stem = Path(filename).stem
    return not re.match('[a-zA-Z]', filename) or stem in KEYWORDS


def apply_prefix(filename: str) -> str:
    """Returns the prefixed filename if needed, otherwise the original."""
    if needs_prefix(filename):
        return f'k{filename}'
    return filename


class TestNamingConventions(unittest.TestCase):

    def test_regular_icon_not_prefixed(self):
        self.assertEqual(apply_prefix('android.svg'), 'android.svg')

    def test_regular_icon_with_hyphen_not_prefixed(self):
        self.assertEqual(apply_prefix('card-plus.svg'), 'card-plus.svg')

    def test_numeric_prefix_gets_k(self):
        self.assertEqual(apply_prefix('4k.svg'), 'k4k.svg')

    def test_numeric_only_gets_k(self):
        self.assertEqual(apply_prefix('123.svg'), 'k123.svg')

    def test_keyword_switch_gets_k(self):
        self.assertEqual(apply_prefix('switch.svg'), 'kswitch.svg')

    def test_keyword_class_gets_k(self):
        self.assertEqual(apply_prefix('class.svg'), 'kclass.svg')

    def test_keyword_import_gets_k(self):
        self.assertEqual(apply_prefix('import.svg'), 'kimport.svg')

    def test_keyword_return_gets_k(self):
        self.assertEqual(apply_prefix('return.svg'), 'kreturn.svg')

    def test_keyword_void_gets_k(self):
        self.assertEqual(apply_prefix('void.svg'), 'kvoid.svg')

    def test_non_keyword_similar_name_not_prefixed(self):
        self.assertEqual(apply_prefix('classes.svg'), 'classes.svg')

    def test_non_keyword_not_prefixed(self):
        self.assertEqual(apply_prefix('arrow.svg'), 'arrow.svg')

    def test_special_char_prefix_gets_k(self):
        self.assertEqual(apply_prefix('-minus.svg'), 'k-minus.svg')

    def test_underscore_prefix_gets_k(self):
        self.assertEqual(apply_prefix('_hidden.svg'), 'k_hidden.svg')


class TestKeywordsSet(unittest.TestCase):

    def test_keywords_is_not_empty(self):
        self.assertGreater(len(KEYWORDS), 0)

    def test_common_dart_keywords_present(self):
        expected = ['class', 'if', 'else', 'for', 'while', 'return',
                    'switch', 'import', 'void', 'null', 'true', 'false']
        for kw in expected:
            self.assertIn(kw, KEYWORDS, f'Missing Dart keyword: {kw}')

    def test_keywords_match_download_script(self):
        """Ensure our test keywords match the actual download.py keywords."""
        import ast
        with open('download/download.py', 'r') as f:
            tree = ast.parse(f.read())

        script_keywords = None
        for node in ast.walk(tree):
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name) and target.id == 'KEYWORDS':
                        script_keywords = ast.literal_eval(node.value)
                        break

        self.assertIsNotNone(script_keywords, 'Could not find KEYWORDS in download.py')
        self.assertEqual(KEYWORDS, script_keywords)


class TestRegexPattern(unittest.TestCase):

    def test_alpha_start_matches(self):
        self.assertIsNotNone(re.match('[a-zA-Z]', 'arrow.svg'))

    def test_numeric_start_does_not_match(self):
        self.assertIsNone(re.match('[a-zA-Z]', '4k.svg'))

    def test_hyphen_start_does_not_match(self):
        self.assertIsNone(re.match('[a-zA-Z]', '-minus.svg'))

    def test_uppercase_matches(self):
        self.assertIsNotNone(re.match('[a-zA-Z]', 'Arrow.svg'))


if __name__ == '__main__':
    unittest.main()
