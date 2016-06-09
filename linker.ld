ENTRY(_start)

SECTIONS
{
	. = 0x1000;

	.text :
	{
		*(.text_first)
		*(.text*)
		. = ALIGN(4K);
	}

	.rdata :
	{
		*(.rdata*)
		. = ALIGN(4K);
	}

	.data :
	{
		*(.data*)
		. = ALIGN(4K);
	}

	.bss :
	{
		*(.bss*)
		. = ALIGN(4K);
	}
}
