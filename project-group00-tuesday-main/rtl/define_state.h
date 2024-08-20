`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [2:0] {
	S_IDLE,
	S_UART_RX,
	S_M1
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [3:0] {
	M1_S_IDLE,
	M1_LI_0,
	M1_LI_1,
	M1_LI_2,
	M1_LI_3,
	M1_LI_4,
	M1_LI_5,
	M1_LI_6,
	M1_LI_7,
	M1_LI_8,
	M1_CC_0,
	M1_CC_1,
	M1_CC_2,
	M1_CC_3,
	M1_CC_4,
	M1_CC_5
} M1_state_type;

typedef enum logic [3:0] {
	M2_S_IDLE,
	M2_LI_0,
	M2_LI_1,
	M2_LI_2,
	M2_LI_3,
	M2_LI_4,
	M2_T_CC_0,
	M2_T_CC_1,
	M2_T_CC_2,
	M2_T_CC_3,
	M2_S_CC_0,
	M2_S_CC_1,
	M2_S_CC_2,
	M2_S_CC_3
} M2_state_type;


parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;


parameter
	Y_START_ADDRESS = 0,
	U_START_ADDRESS = 38400,
	V_START_ADDRESS = 57600,
	RGB_START_ADDRESS = 146944;

parameter
	IDCT_ADDRESS = 76800,
	M2_WRITE_ADDRESS = 0;

`define DEFINE_STATE 1
`endif
