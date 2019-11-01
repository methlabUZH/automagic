function result = hlp_memfree
% Get the amount of free physical memory, in bytes
result = java.lang.management.ManagementFactory.getOperatingSystemMXBean().getFreePhysicalMemorySize();
