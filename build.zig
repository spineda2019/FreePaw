// build script for the FreePaw bootloader
// Copyright (C) 2025  Sebastian Pineda (spineda.wpi.alum@gmail.com)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const install = b.getInstallStep();
    const bootloader = b.step("bootloader", "Build OpenPaw Bootloader");
    install.dependOn(bootloader);

    const bootloader_assembly = b.path("architecture/x86/bootsector.asm");
    const obj_output = "bootsector.o";
    const linker_output = "bootsector_tmp.o";
    const boot_output = "boot.bin";

    const gnu_assembler = b.addSystemCommand(&[_][]const u8{
        "as",
        bootloader_assembly.getPath(b),
        "-o",
        obj_output,
    });
    const gnu_linker = b.addSystemCommand(&[_][]const u8{
        "ld",
        "-o",
        linker_output,
        "-Ttext",
        "0x7c00",
    });
    const final_bootloader = b.addSystemCommand(&[_][]const u8{
        "objcopy",
        "-O",
        "binary",
        "-j",
        ".text",
        linker_output,
        boot_output,
    });

    final_bootloader.step.dependOn(&gnu_linker.step);
    gnu_linker.step.dependOn(&gnu_assembler.step);
    gnu_assembler.step.dependOn(bootloader);
}
