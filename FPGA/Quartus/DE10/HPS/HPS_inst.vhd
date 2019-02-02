	component HPS is
		port (
			memory_mem_a                     : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                    : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                    : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                  : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                   : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                  : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                 : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                 : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                  : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n               : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                    : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs                   : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                 : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                   : out   std_logic;                                        -- mem_odt
			memory_mem_dm                    : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin                 : in    std_logic                     := 'X';             -- oct_rzqin
			hps_io_hps_io_gpio_inst_LOANIO01 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO01
			hps_io_hps_io_gpio_inst_LOANIO02 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO02
			hps_io_hps_io_gpio_inst_LOANIO03 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO03
			hps_io_hps_io_gpio_inst_LOANIO04 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO04
			hps_io_hps_io_gpio_inst_LOANIO05 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO05
			hps_io_hps_io_gpio_inst_LOANIO06 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO06
			hps_io_hps_io_gpio_inst_LOANIO07 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO07
			hps_io_hps_io_gpio_inst_LOANIO08 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO08
			hps_io_hps_io_gpio_inst_LOANIO10 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO10
			hps_io_hps_io_gpio_inst_LOANIO11 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO11
			hps_io_hps_io_gpio_inst_LOANIO12 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO12
			hps_io_hps_io_gpio_inst_LOANIO13 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO13
			hps_io_hps_io_gpio_inst_LOANIO42 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO42
			hps_io_hps_io_gpio_inst_LOANIO49 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO49
			hps_io_hps_io_gpio_inst_LOANIO50 : inout std_logic                     := 'X';             -- hps_io_gpio_inst_LOANIO50
			loanio_in                        : out   std_logic_vector(66 downto 0);                    -- in
			loanio_out                       : in    std_logic_vector(66 downto 0) := (others => 'X'); -- out
			loanio_oe                        : in    std_logic_vector(66 downto 0) := (others => 'X'); -- oe
			hps_gp_gp_in                     : in    std_logic_vector(31 downto 0) := (others => 'X'); -- gp_in
			hps_gp_gp_out                    : out   std_logic_vector(31 downto 0)                     -- gp_out
		);
	end component HPS;

	u0 : component HPS
		port map (
			memory_mem_a                     => CONNECTED_TO_memory_mem_a,                     -- memory.mem_a
			memory_mem_ba                    => CONNECTED_TO_memory_mem_ba,                    --       .mem_ba
			memory_mem_ck                    => CONNECTED_TO_memory_mem_ck,                    --       .mem_ck
			memory_mem_ck_n                  => CONNECTED_TO_memory_mem_ck_n,                  --       .mem_ck_n
			memory_mem_cke                   => CONNECTED_TO_memory_mem_cke,                   --       .mem_cke
			memory_mem_cs_n                  => CONNECTED_TO_memory_mem_cs_n,                  --       .mem_cs_n
			memory_mem_ras_n                 => CONNECTED_TO_memory_mem_ras_n,                 --       .mem_ras_n
			memory_mem_cas_n                 => CONNECTED_TO_memory_mem_cas_n,                 --       .mem_cas_n
			memory_mem_we_n                  => CONNECTED_TO_memory_mem_we_n,                  --       .mem_we_n
			memory_mem_reset_n               => CONNECTED_TO_memory_mem_reset_n,               --       .mem_reset_n
			memory_mem_dq                    => CONNECTED_TO_memory_mem_dq,                    --       .mem_dq
			memory_mem_dqs                   => CONNECTED_TO_memory_mem_dqs,                   --       .mem_dqs
			memory_mem_dqs_n                 => CONNECTED_TO_memory_mem_dqs_n,                 --       .mem_dqs_n
			memory_mem_odt                   => CONNECTED_TO_memory_mem_odt,                   --       .mem_odt
			memory_mem_dm                    => CONNECTED_TO_memory_mem_dm,                    --       .mem_dm
			memory_oct_rzqin                 => CONNECTED_TO_memory_oct_rzqin,                 --       .oct_rzqin
			hps_io_hps_io_gpio_inst_LOANIO01 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO01, -- hps_io.hps_io_gpio_inst_LOANIO01
			hps_io_hps_io_gpio_inst_LOANIO02 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO02, --       .hps_io_gpio_inst_LOANIO02
			hps_io_hps_io_gpio_inst_LOANIO03 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO03, --       .hps_io_gpio_inst_LOANIO03
			hps_io_hps_io_gpio_inst_LOANIO04 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO04, --       .hps_io_gpio_inst_LOANIO04
			hps_io_hps_io_gpio_inst_LOANIO05 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO05, --       .hps_io_gpio_inst_LOANIO05
			hps_io_hps_io_gpio_inst_LOANIO06 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO06, --       .hps_io_gpio_inst_LOANIO06
			hps_io_hps_io_gpio_inst_LOANIO07 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO07, --       .hps_io_gpio_inst_LOANIO07
			hps_io_hps_io_gpio_inst_LOANIO08 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO08, --       .hps_io_gpio_inst_LOANIO08
			hps_io_hps_io_gpio_inst_LOANIO10 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO10, --       .hps_io_gpio_inst_LOANIO10
			hps_io_hps_io_gpio_inst_LOANIO11 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO11, --       .hps_io_gpio_inst_LOANIO11
			hps_io_hps_io_gpio_inst_LOANIO12 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO12, --       .hps_io_gpio_inst_LOANIO12
			hps_io_hps_io_gpio_inst_LOANIO13 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO13, --       .hps_io_gpio_inst_LOANIO13
			hps_io_hps_io_gpio_inst_LOANIO42 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO42, --       .hps_io_gpio_inst_LOANIO42
			hps_io_hps_io_gpio_inst_LOANIO49 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO49, --       .hps_io_gpio_inst_LOANIO49
			hps_io_hps_io_gpio_inst_LOANIO50 => CONNECTED_TO_hps_io_hps_io_gpio_inst_LOANIO50, --       .hps_io_gpio_inst_LOANIO50
			loanio_in                        => CONNECTED_TO_loanio_in,                        -- loanio.in
			loanio_out                       => CONNECTED_TO_loanio_out,                       --       .out
			loanio_oe                        => CONNECTED_TO_loanio_oe,                        --       .oe
			hps_gp_gp_in                     => CONNECTED_TO_hps_gp_gp_in,                     -- hps_gp.gp_in
			hps_gp_gp_out                    => CONNECTED_TO_hps_gp_gp_out                     --       .gp_out
		);

