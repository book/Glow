requires "strict";
requires "warnings";

requires "Digest";
requires "Encode";
requires "FileHandle";
requires "Fcntl";
requires "IO::File";
requires "List::Util";

requires "Moose";
requires "Moose::Role";
requires "MooseX::Role::Parameterized";
requires "MooseX::Types::Path::Class";
requires "namespace::autoclean";

requires "Config::GitLike";

requires "DateTime";
requires "DateTime::TimeZone";

requires "IO::Compress::Deflate";
requires "IO::Uncompress::Inflate";
requires "IO::String";

requires "Path::Class::Dir";
requires "Path::Class::File";

on test => sub {
	requires "File::Temp";
	requires "Test::More";
};

on develop => sub {
	requires "Dist::Zilla::PluginBundle::Filter";
	requires "Dist::Zilla::PluginBundle::Git";

	requires "Dist::Zilla::Plugin::AutoPrereqs";
	requires "Dist::Zilla::Plugin::Git::NextVersion";
	requires "Dist::Zilla::Plugin::MetaResources";
	requires "Dist::Zilla::Plugin::NextRelease";
	requires "Dist::Zilla::Plugin::PkgVersion";
	requires "Dist::Zilla::Plugin::PodWeaver";
	requires "Dist::Zilla::Plugin::Prereqs";
	requires "Dist::Zilla::Plugin::PruneFiles";
	requires "Dist::Zilla::Plugin::ReportVersions::Tiny";
};
