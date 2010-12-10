use inc::Module::Install;

name 'Cybozu-Garoon-Notify';
all_from 'lib/Cybozu/Garoon/Notify.pm';
readme_from 'lib/Cybozu/Garoon/Notify.pm';
license 'perl';

requires 'Cache::LRU';
requires 'Class::Accessor::Lite' => 0.05;
requires 'Config::Simple';
requires 'DateTime';
requires 'DateTime::Format::Strptime';
requires 'DateTime::Duration';
requires 'LWP::UserAgent';
requires 'XML::Simple';

test_requires 'Test::More' => 0.88;

install_script 'garoon2growl';

auto_include;
auto_install;

WriteAll;
