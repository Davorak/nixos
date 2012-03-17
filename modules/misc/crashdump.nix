{pkgs, config, ...}:

with pkgs.lib;

let
  crashdump = config.boot.crashDump;
in
###### interface
{
  options = {
    boot = {
      crashDump = {
        enable = mkOption {
          default = false;
          example = true;
          description = ''
            If enabled, NixOS will set up a kernel that will
            boot on crash, and leave the user to a stage1 debug1devices
            interactive shell to be able to save the crashed kernel dump.
            It also activates the NMI watchdog.
          '';
        };
        kernelPackages = mkOption {
          default = pkgs.linuxPackages;
          # We don't want to evaluate all of linuxPackages for the manual
          # - some of it might not even evaluate correctly.
          defaultText = "pkgs.linuxPackages";
          example = "pkgs.linuxPackages_2_6_25";
          description = ''
            This will override the boot.kernelPackages, and will add some
            kernel configuration parameters for the crash dump to work.
          '';
        };
      };
    };
  };

###### implementation

  config = mkIf crashdump.enable {
    boot = {
      postBootCommands = ''
        ${pkgs.kexectools}/sbin/kexec -p /var/run/current-system/kernel \
        --initrd=/var/run/current-system/initrd \
        --append="init=$(readlink -f /var/run/current-system/init) system=$(readlink -f /var/run/current-system) debug1devices irqpoll maxcpus=1 reset_devices" --reset-vga --console-vga
      '';
      kernelParams = [
       "crashkernel=64M"
       "nmi_watchdog=1"
      ];
      kernelPackages = mkOverride 200 (crashdump.kernelPackages // {
        kernel = crashdump.kernelPackages.kernel.override 
          (attrs: {
            extraConfig = (optionalString (attrs ? extraConfig) attrs.extraConfig) +
              ''
                CRASH_DUMP y
                DEBUG_INFO y
                PROC_VMCORE y
              '';
          });
      });
    };
  };
}