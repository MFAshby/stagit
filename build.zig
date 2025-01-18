const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libgit2_dep = b.dependency("libgit2", .{
        .target = target,
        .optimize = optimize,
        .@"enable-ssh" = true, // optional ssh support via libssh2
    });
    const stagit_dep = b.dependency("stagit", .{});
    const compat_sources: []const []const u8 = &.{ "reallocarray.c", "strlcat.c", "strlcpy.c" };

    const stagit_exe = b.addExecutable(.{
        .name = "stagit",
        .target = target,
        .optimize = optimize,
    });
    inline for (compat_sources) |src| {
        stagit_exe.addCSourceFile(.{ .file = stagit_dep.path(src) });
    }
    stagit_exe.addCSourceFile(.{ .file = stagit_dep.path("stagit.c") });
    stagit_exe.linkLibrary(libgit2_dep.artifact("git2"));
    b.installArtifact(stagit_exe);
    const stagit_index_exe = b.addExecutable(.{
        .name = "stagit-index",
        .target = target,
        .optimize = optimize,
    });
    // inline for (compat_sources) |src| {
    //     stagit_exe.addCSourceFile(.{ .file = stagit_dep.path(src) });
    // }
    stagit_index_exe.addCSourceFile(.{ .file = stagit_dep.path("stagit-index.c") });
    stagit_index_exe.linkLibrary(libgit2_dep.artifact("git2"));
    b.installArtifact(stagit_index_exe);

    const docfiles: []const []const u8 = &.{ "style.css", "favicon.png", "logo.png", "example_create.sh", "example_post-receive.sh", "README" };
    inline for (docfiles) |docfile| {
        b.getInstallStep().dependOn(&b.addInstallFileWithDir(stagit_dep.path(docfile), .prefix, "share/doc/stagit/" ++ docfile).step);
    }
    const man1files: []const []const u8 = &.{ "stagit.1", "stagit-index.1" };
    inline for (man1files) |man1file| {
        b.getInstallStep().dependOn(&b.addInstallFileWithDir(stagit_dep.path(man1file), .prefix, "man/man1/" ++ man1file).step);
    }
}
