OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY
{
    /* Run in FLASH */ 
    flash (rx)  : ORIGIN = 0x08000000, LENGTH = 4096K
    ram   (rwx) : ORIGIN = 0x20000000, LENGTH = 288K
    /* Run in RAM */ 
	/* flash (rxai!w) : ORIGIN = 0x20000000, LENGTH = 32k
	ram   (wxa!ri) : ORIGIN = 0x20008000, LENGTH = 256K */
}

__stack_size = DEFINED(__stack_size) ? __stack_size : 2K;

SECTIONS
{
    /* 代码段 */
    .text :
    {
        *(.init)
        *(.text .text.*)
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        *(.gnu.linkonce.t.*)
        *(.gnu.linkonce.r.*)
        KEEP(*(.ctors))
        KEEP(*(.dtors))
    } >flash

    /* 标记 text 结束 */
    PROVIDE(__etext = .);
    PROVIDE(_etext = .);
    PROVIDE(_data_lma = __etext); /* 添加这个，给你的start.S用 */

    /* 初始化数组 */
    .init_array :
    {
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN(__init_array_end = .);
    } >flash

    .fini_array :
    {
        PROVIDE_HIDDEN(__fini_array_start = .);
        KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN(__fini_array_end = .);
    } >flash

    /* .data段，运行时搬到RAM */
    .data : AT(_data_lma)
    {
        PROVIDE(_data = .);
        *(.data .data.*)
        *(.sdata .sdata.*)
        *(.gnu.linkonce.d.*)
        *(.gnu.linkonce.s.*)
        PROVIDE(__global_pointer$ = . + 0x800); /* 小数据区基地址 */
    } >ram

    PROVIDE(_edata = .);

    /* BSS段 */
    .bss (NOLOAD) :
    {
        PROVIDE(__bss_start = .);
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
    } >ram

    PROVIDE(__bss_end = .);
    PROVIDE(_end = .);
    PROVIDE(end = .);

    /* 堆 */
    .heap (NOLOAD) :
    {
        __heap_start__ = .;
        PROVIDE(_heap_end = .); /* 堆起始符号 */
    } >ram

    /* 栈 */
    .stack (NOLOAD) :
    {
        __stack_top__ = ORIGIN(ram) + LENGTH(ram);
        __stack_bottom__ = __stack_top__ - __stack_size;
        PROVIDE(__stack_start__ = __stack_bottom__);
        PROVIDE(_sp = __stack_top__);
    } >ram
}
