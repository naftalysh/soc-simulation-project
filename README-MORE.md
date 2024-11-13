* Hardware Simulators
Hardware simulators are used to model and test system-on-chip (SOC) performance before actual deployment on hardware. 
Popular simulators in this space include QEMU and Synopsys VCS, providing insights into system behavior under different workloads.
Best practices involve setting accurate simulation parameters, using realistic workloads, and validating results against real hardware where possible.
• QEMU: A generic open-source machine emulator and virtualizer.
   - Official Site: https://www.qemu.org
   - Best Practices: https://wiki.qemu.org/Documentation
• Synopsys VCS: A widely-used simulator for verifying SOC designs.
   - Official Site: https://www.synopsys.com

(Spark Application prerequisites) 
* Install Docker Buildx:
  docker plugin install docker/buildx-plugin:latest

  --> Error response from daemon: error resolving plugin reference: pull access denied, repository does not exist or may require authorization: server 
      message: insufficient_scope: authorization failed

* Determine whether our Windows Subsystem for Linux (WSL) environment can mount and use an NBD (Network Block Device) device, 
  follow these steps. This guide covers checking WSL version, verifying NBD support, attempting to use NBD, and exploring alternatives if necessary
  1. How to find our WSL distributions and WSL Version (we need a distribution of version 2)
    wsl --list --verbose
    NAME                      STATE           VERSION
    * Ubuntu                    Running         2
      podman-machine-default    Running         2

      Meaning Ubuntu is the active distribution
      To choose the Ubuntu distribution if it's not active: wsl -d Ubuntu

  2. Verify NBD Module Availability
     - Check if NBD is Loaded:
       Open your WSL terminal and run:  lsmod | grep nbd
       If we see the output: "nbd  45056  0", It means the NBD module is already loaded

       If there’s no output, 
     - Attempt to load the NBD module (defaults to 31 max partitions):  sudo modprobe nbd, 
       or to load the NBD module with Specific Parameters: sudo modprobe nbd max_part=8 
       (allows up to 8 partitions on the NBD device, /dev/nbd0p1 to /dev/nbd0p8)

       Notes: 
       - In WSL2, modprobe might fail with an error like FATAL: Module nbd not found., indicating that the module isn't available in the current kernel.
       - nbds_max Parameter: Determines the maximum number of NBD devices that can be concurrently managed by the kernel (defaults to 16)
       - To confirm that the module has been loaded with the desired parameters: cat /sys/module/nbd/parameters/max_part 
  3. Install the nbd-client Package
     sudo apt-get update
     sudo apt-get install nbd-client

    


       



* debugging
  * docker-compose  logs -f | grep -A 1 -B 1 -i 'error\|warning\|fail'