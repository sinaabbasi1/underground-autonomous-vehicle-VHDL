library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity project_tb is
end project_tb;

architecture TB_ARCHITECTURE of project_tb is
	-- Component declaration of the tested unit
	component project
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC := '1';
		start : in STD_LOGIC;
		speed : in STD_LOGIC_VECTOR(2 downto 0);
		stations : in STD_LOGIC_VECTOR(0 to 47);
		stop : in STD_LOGIC;
		emergency : in STD_LOGIC;
		chance : in STD_LOGIC;
		moving : out STD_LOGIC;
		station_num : out STD_LOGIC_VECTOR(3 downto 0);
		station_halt : out STD_LOGIC_VECTOR(3 downto 0);
		nextstation_left : out STD_LOGIC_VECTOR(7 downto 0);
		time_left : out STD_LOGIC_VECTOR(7 downto 0);
		total_time : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC := '1';
	signal reset : STD_LOGIC := '1';
	signal start : STD_LOGIC := '0';
	signal speed : STD_LOGIC_VECTOR(2 downto 0) := "011";
	signal stations : STD_LOGIC_VECTOR(0 to 47) := "001000100101001110100010100001101110000100110010";
	signal stop : STD_LOGIC := '0';
	signal emergency : STD_LOGIC := '0';
	signal chance : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal moving : STD_LOGIC;
	signal station_num : STD_LOGIC_VECTOR(3 downto 0);
	signal station_halt : STD_LOGIC_VECTOR(3 downto 0);
	signal nextstation_left : STD_LOGIC_VECTOR(7 downto 0);
	signal time_left : STD_LOGIC_VECTOR(7 downto 0);
	signal total_time : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : project
		port map (
			clk => clk,
			reset => reset,
			start => start,
			speed => speed,
			stations => stations,
			stop => stop,
			emergency => emergency,
			chance => chance,
			moving => moving,
			station_num => station_num,
			station_halt => station_halt,
			nextstation_left => nextstation_left,
			time_left => time_left,
			total_time => total_time
		);

	-- Add your stimulus here ...
	reset <= '0' after 3 ns;
	clk <= not clk after 1ns;
	start <= '1' after 5ns, '0' after 7ns;
	stop <= '1' after 420 ns, '0' after 455 ns;
	emergency <= '1' after 709ns, '0' after 711ns;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_project of project_tb is
	for TB_ARCHITECTURE
		for UUT : project
			use entity work.project(arch);
		end for;
	end for;
end TESTBENCH_FOR_project;

