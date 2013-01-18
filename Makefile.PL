use inc::Module::Install;
name 'Plack-Middleware-ErrorWithGitBlame';
all_from 'lib/Plack/Middleware/ErrorWithGitBlame.pm';

requires 'Plack';
requires 'Git::Class';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::TCP';
test_requires 'Path::Class';
test_requires 'Guard';
auto_set_repository;
auto_include;
WriteAll;
