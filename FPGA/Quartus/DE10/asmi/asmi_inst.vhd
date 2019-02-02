	component asmi is
		port (
			clkin      : in  std_logic                     := 'X';             -- clk
			read       : in  std_logic                     := 'X';             -- read
			rden       : in  std_logic                     := 'X';             -- rden
			addr       : in  std_logic_vector(23 downto 0) := (others => 'X'); -- addr
			reset      : in  std_logic                     := 'X';             -- reset
			dataout    : out std_logic_vector(7 downto 0);                     -- dataout
			busy       : out std_logic;                                        -- busy
			data_valid : out std_logic                                         -- data_valid
		);
	end component asmi;

	u0 : component asmi
		port map (
			clkin      => CONNECTED_TO_clkin,      --      clkin.clk
			read       => CONNECTED_TO_read,       --       read.read
			rden       => CONNECTED_TO_rden,       --       rden.rden
			addr       => CONNECTED_TO_addr,       --       addr.addr
			reset      => CONNECTED_TO_reset,      --      reset.reset
			dataout    => CONNECTED_TO_dataout,    --    dataout.dataout
			busy       => CONNECTED_TO_busy,       --       busy.busy
			data_valid => CONNECTED_TO_data_valid  -- data_valid.data_valid
		);

