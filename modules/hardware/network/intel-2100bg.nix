{pkgs, config, ...}:

{

  ###### interface

  options = {

    networking.enableIntel2100BGFirmware = pkgs.lib.mkOption {
      default = false;
      type = pkgs.lib.types.bool;
      description = ''
        Turn on this option if you want firmware for the Intel
        PRO/Wireless 2100BG to be loaded automatically.  This is
        required if you want to use this device.  Intel requires you to
        accept the license for this firmware, see
        <link xlink:href='http://ipw2100.sourceforge.net/firmware.php?fid=2'/>.
      '';
    };

  };


  ###### implementation

  config = pkgs.lib.mkIf config.networking.enableIntel2100BGFirmware {

    # Warning: setting this option requires acceptance of the firmware
    # license, see http://ipw2100.sourceforge.net/firmware.php?fid=2.
    hardware.firmware = [ pkgs.ipw2100fw ];

  };

}
