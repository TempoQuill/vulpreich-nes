MACRO text_end
	.db text_end_cmd
ENDM

MACRO next text
	.db text_next_cmd, text
ENDM

MACRO para text
	.db text_para_cmd, text
ENDM

MACRO line text
	.db text_line_cmd, text
ENDM

MACRO cont text
	.db text_cont_cmd, text
ENDM

MACRO done
	.db text_done_cmd
ENDM
