-------------------------------------------------------------------------------
--
-- Title       : Project
-- Design      : Tamrin2
-- Author      : 
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : Project.vhd
-- Generated   : Wed Jan 13 15:49:12 2021
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {Project} architecture {arch}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Project is
	port(
	clk: in std_logic;
	reset: in std_logic;
	start: in std_logic;
	speed: in std_logic_vector(2 downto 0);
	stations: in std_logic_vector(0 to 47);
	stop: in std_logic;
	emergency: in std_logic;
	chance: in std_logic;
	moving: out std_logic; -- '1' for moving & '0' for halt
	station_num: out std_logic_vector(3 downto 0);
	station_halt: out std_logic_vector(3 downto 0);
	nextstation_left: out std_logic_vector(7 downto 0);
	time_left: out std_logic_vector(7 downto 0);
	total_time: out std_logic_vector(7 downto 0));
end Project;

--}} End of automatically maintained section

architecture arch of Project is

type state_type is (s0, s1, s2, s3, s4, s5, s6, s0s1, s1s2, s2s3, s3s4, s4s5, s5s6, s6s0, emerge, dummy); 
signal state, next_state, last_state, next_last_state: state_type;
signal p1, t1, p2, t2, p3, t3, p4, t4, p5, t5, p6, t6, emergency_station: std_logic_vector(3 downto 0);  
signal m0, m1, m2, m3, m4, m5, m6: std_logic_vector(9 downto 0);
signal counter, midcounter, tot_time, em_counter, mid_em_counter, mid_time_left: integer; 
signal start_flag, set, em_set, emergency_flag: std_logic;
signal moving_sig: std_logic;

begin
	
	-- P(num) for station number and T(sec) for halt time at each station
	p1 <= stations(0 to 3);
	t1 <= stations(4 to 7);
	p2 <= stations(8 to 11);
	t2 <= stations(12 to 15);
	p3 <= stations(16 to 19);
	t3 <= stations(20 to 23);
	p4 <= stations(24 to 27);
	t4 <= stations(28 to 31);
	p5 <= stations(32 to 35);
	t5 <= stations(36 to 39);
	p6 <= stations(40 to 43);
	t6 <= stations(44 to 47);
	
	-- M for moving time(seconds)										
	-- first unsigned for arithmetic then signed to use ((abs)) the unsigned for arithmetic again 	
	m0 <= std_logic_vector((unsigned('0' & p1) * 5) / unsigned(speed));
	m1 <= std_logic_vector(unsigned(abs(signed(unsigned('0' & p2) - unsigned('0' & p1))) * 5) / unsigned(speed));
	m2 <= std_logic_vector(unsigned(abs(signed(unsigned('0' & p3) - unsigned('0' & p2))) * 5) / unsigned(speed));
	m3 <= std_logic_vector(unsigned(abs(signed(unsigned('0' & p4) - unsigned('0' & p3))) * 5) / unsigned(speed));
	m4 <= std_logic_vector(unsigned(abs(signed(unsigned('0' & p5) - unsigned('0' & p4))) * 5) / unsigned(speed));
	m5 <= std_logic_vector(unsigned(abs(signed(unsigned('0' & p6) - unsigned('0' & p5))) * 5) / unsigned(speed));
	m6 <= std_logic_vector((unsigned('0' & p6) * 5) / unsigned(speed));
	
	-- FSM Clocked Process
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= s0;
		elsif clk'event and clk = '1' then
			state <= next_state;
		end if;
	end process;
	
	-- FSM Combinational Process
	process(state, start, stop, counter,p1,p2,p3,p4,p5,p6,emergency_station,last_state,m0,m1,m2,m3,m4,m5,m6,emergency,midcounter,t1,t2,t3,t4,t5,t6, mid_em_counter) --@#$%%^&&*(())
	variable a: integer;
	begin
		next_state <= state; --avoid latches 
		set <= '1';
		counter <= 0;
		station_num <= p1;
		--emergency_station <= "0000";
		em_counter <= 0;
		em_set <= '1';
		next_last_state <= last_state;
		moving_sig <= '0';
		
		case state is
			when s0 =>
			set <= '0';
			station_num <= "0000"; 
			moving_sig <= '0';
			if start = '1' and stop = '0' then
				next_state <= s0s1;
				counter <= to_integer(unsigned(m0)) * 10;
				set <= '1';
			end if;
			when s0s1 => 
			set <= '0';
			station_num <= p1;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then
					emergency_station <= std_logic_vector("0000" + (unsigned(p1) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s0s1;
				elsif midcounter = 0 then
					next_state <= s1;
					counter <= to_integer(unsigned(t1)) * 10;
					set <= '1';
				end if;
			end if;
			when s1 =>
			set <= '0';
			station_num <= p1;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s1s2;
				counter <= to_integer(unsigned(m1)) * 10;
				set <= '1';
			end if;
			when s1s2 =>
			set <= '0';
			station_num <= p2;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then
					if unsigned(p1) < unsigned(p2) then
						emergency_station <= std_logic_vector(unsigned(p1) + (unsigned(abs(signed(unsigned(p2) - unsigned(p1)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					else
						emergency_station <= std_logic_vector(unsigned(p1) - (unsigned(abs(signed(unsigned(p2) - unsigned(p1)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					end if;
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s1s2;
				elsif midcounter = 0 then
					next_state <= s2;
					counter <= to_integer(unsigned(t2)) * 10;
					set <= '1';
				end if;
			end if;
			when s2 =>
			set <= '0';
			station_num <= p2;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s2s3;
				counter <= to_integer(unsigned(m2)) * 10;
				set <= '1';
			end if;
			when s2s3 =>
			set <= '0';
			station_num <= p3;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then	
					if unsigned(p2) < unsigned(p3) then
						emergency_station <= std_logic_vector(unsigned(p2) + (unsigned(abs(signed(unsigned(p3) - unsigned(p2)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					else
						emergency_station <= std_logic_vector(unsigned(p2) - (unsigned(abs(signed(unsigned(p3) - unsigned(p2)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					end if;
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s2s3;
				elsif midcounter = 0 then
					next_state <= s3; 
					counter <= to_integer(unsigned(t3)) * 10;
					set <= '1';
				end if;
			end if;
			when s3 =>
			set <= '0';
			station_num <= p3;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s3s4;
				counter <= to_integer(unsigned(m3)) * 10;
				set <= '1';
			end if;
			when s3s4 =>
			set <= '0';
			station_num <= p4;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then
					if unsigned(p3) < unsigned(p4) then
						emergency_station <= std_logic_vector(unsigned(p3) + (unsigned(abs(signed(unsigned(p4) - unsigned(p3)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					else
						emergency_station <= std_logic_vector(unsigned(p3) - (unsigned(abs(signed(unsigned(p4) - unsigned(p3)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					end if;
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s3s4;
				elsif midcounter = 0 then
					next_state <= s4;
					counter <= to_integer(unsigned(t4)) * 10;
					set <= '1';
				end if;
			end if;
			when s4 =>
			set <= '0';
			station_num <= p4;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s4s5;
				counter <= to_integer(unsigned(m4)) * 10;
				set <= '1';
			end if;
			when s4s5 =>
			set <= '0';
			station_num <= p5;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then
					if unsigned(p4) < unsigned(p5) then
						emergency_station <= std_logic_vector(unsigned(p4) + (unsigned(abs(signed(unsigned(p5) - unsigned(p4)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					else
						emergency_station <= std_logic_vector(unsigned(p4) - (unsigned(abs(signed(unsigned(p5) - unsigned(p4)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					end if;
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s4s5;
				elsif midcounter = 0 then
					next_state <= s5;
					counter <= to_integer(unsigned(t5)) * 10;
					set <= '1';
				end if;
			end if;
			when s5 => 
			set <= '0';
			station_num <= p5;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s5s6;
				counter <= to_integer(unsigned(m5)) * 10; 
				set <= '1';
			end if;
			when s5s6 =>
			set <= '0';
			station_num <= p6;
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then	
					if unsigned(p5) < unsigned(p6) then
						emergency_station <= std_logic_vector(unsigned(p5) + (unsigned(abs(signed(unsigned(p6) - unsigned(p5)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					else
						emergency_station <= std_logic_vector(unsigned(p5) - (unsigned(abs(signed(unsigned(p6) - unsigned(p5)))) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					end if;
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s5s6;
				elsif midcounter = 0 then
					next_state <= s6;
					counter <= to_integer(unsigned(t6)) * 10;
					set <= '1';
				end if;
			end if;
			when s6 =>
			set <= '0';
			station_num <= p6;
			moving_sig <= '0';
			if midcounter = 0 and stop = '0' then
				next_state <= s6s0;
				counter <= to_integer(unsigned(m6)) * 10;
				set <= '1';
			end if;
			when s6s0 => 
			set <= '0';
			station_num <= "0000";
			moving_sig <= '1';
			if stop = '0' then
				if emergency = '1' then
					emergency_station <= std_logic_vector(unsigned(p6) - (unsigned(p6) - to_unsigned(((midcounter / 10) * to_integer(unsigned(speed)))/5, 4)));
					next_state <= emerge;
					em_counter <= 10 * 10; 
					em_set <= '1';
					next_last_state <= s6s0;
				elsif midcounter = 0 then
					next_state <= s0;
				end if;
			end if;
			when emerge =>
			em_set <= '0';
			station_num <= emergency_station;
			moving_sig <= '0';
			if mid_em_counter = 0 and stop = '0' then
				next_state <= last_state; 
			end if;
			when dummy =>
			if counter = 0 and stop = '0' then
				next_state <= s0;
			end if;
		end case;
	end process;
	
	-- flip-flop for saving what state we were before emergency state
	process(clk, reset)
	begin
		if(reset = '1') then
			last_state <= s0;
		elsif clk'event and clk = '1' then
			last_state <= next_last_state;
		end if;
	end process;
	
	-- counter for halt & move
	process(clk)
	begin
		if clk'event and clk = '1' then
			if stop = '1' or state = emerge then 
				null;
			elsif start_flag = '1' then
				if set = '1' then
					midcounter <= counter;
				else
					midcounter <= midcounter - 1;
				end if;
			end if;
		end if;
	end process; 
	
	-- counter for emergency
	process(clk)
	begin
		if clk'event and clk = '1' then
			if stop = '1'  then --or state /= emerge
				null;
			else
				if em_set = '1' then 
					mid_em_counter <= em_counter;
				else
					mid_em_counter <= mid_em_counter - 1;
				end if;
			end if;
		end if;
	end process; 	
	
	-- counter for total_time
	process(clk, reset)
	-- variable flag: integer;
	begin
		if(reset = '1') then
			tot_time <= 0;
		elsif clk'event and clk = '1' then
			if start = '1' then 
				tot_time <= 0;
				-- flag := 1;
			elsif start_flag = '1' then 
				tot_time <= tot_time + 1;
			end if;
		end if;
	end process;
	
	-- start flag
	process(start, reset, state)
	begin
		if start = '1' then
			start_flag <= '1';
		elsif reset = '1' or state = s0 then -- or state = s0
			start_flag <= '0';
		end if;
	end process;
	
	-- time_left
	process(clk)
	begin
		if clk'event and clk = '1' then
			if stop = '1' then 
				null;
			elsif start = '1' then
				mid_time_left <= to_integer(unsigned(m0)+unsigned(m1)+unsigned(m2)+unsigned(m3)+unsigned(m4)+unsigned(m5)+unsigned(m6)+unsigned(t1)
				+ unsigned(t2)+unsigned(t3)+unsigned(t4)+unsigned(t5)+unsigned(t6)) * 10; 
			elsif start_flag = '1' then
				if emergency = '1' then
					mid_time_left <= mid_time_left + (10 * 10) + 10;
				else
					mid_time_left <= mid_time_left - 1;
				end if;
			end if;
		end if;
	end process; 
	
	time_left <= std_logic_vector(to_unsigned(mid_time_left / 10, 8)) when mid_time_left > 0 else "00000000";
	
		
	-- station_halt & nextstation_left
	process(moving_sig, midcounter, mid_em_counter, state)
	begin  
		if moving_sig = '1' then
			station_halt <= "0000";	
			if midcounter > 0 then
				nextstation_left <= std_logic_vector(to_unsigned(midcounter/10, 8));
			else
			 	nextstation_left <= "00000000";	
			end if;
		else
			if midcounter > 0 then
				if state = emerge and mid_em_counter > 0 then
					station_halt <= std_logic_vector(to_unsigned(mid_em_counter/10, 4));
				else 
					station_halt <= std_logic_vector(to_unsigned(midcounter/10, 4));
				end if;
			else
			 	station_halt <= "0000";
			end if;
			nextstation_left <= "00000000";
		end if;
	end process;
	
	
	total_time <= std_logic_vector(to_unsigned(tot_time / 10, 8)) when tot_time > 0 else "00000000";
	
	moving <= moving_sig when stop = '0' else '0';
	
end arch;
