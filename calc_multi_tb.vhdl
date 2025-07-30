library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_multi_tb is
end calc_multi_tb;

architecture tb of calc_multi_tb is

    component calc_multi
    port(
        clk:          in std_logic;
        reset:        in std_logic;
        instruction:  in std_logic_vector(7 downto 0);
        pc_out:       out std_logic_vector(3 downto 0);
        printout:     out std_logic_vector(15 downto 0)
    );
    end component;
    
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal instruction_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_out_tb : std_logic_vector(3 downto 0);
    signal printout_tb : std_logic_vector(15 downto 0);
    
    constant clk_period : time := 10 ns;
    constant cycles_per_instr : integer := 4; --FETCH, ID, EXE, WB

begin

    calc: calc_multi port map (
        clk => clk_tb,
        reset => reset_tb,
        instruction => instruction_tb,
        pc_out => pc_out_tb,
        printout => printout_tb
    );

    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;
    
    test: process
        procedure wait_cycles(n: integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk_tb);
            end loop;
        end procedure;
        
        procedure execute_instruction(instr: std_logic_vector(7 downto 0)) is
        begin
            instruction_tb <= instr;
            wait_cycles(cycles_per_instr);
            --extra wait to ensure printout is updated
            wait for 1 ns;
        end procedure;
        
        procedure check_output(expected: integer) is
            variable printout_int: integer;
        begin
            printout_int := to_integer(signed(printout_tb));
            if printout_int = expected then
                report "PASS -> " & integer'image(expected) & " == " & integer'image(printout_int);
            else
                report "FAIL -> " & integer'image(expected) & " != " & integer'image(printout_int) severity error;
            end if;
        end procedure;

    begin

        wait for clk_period;
        reset_tb <= '1';
        wait_cycles(2);
        reset_tb <= '0';
        wait_cycles(2);

        report "Test 1: Loading immediate values into registers";
        
        --load 5 into r0
        execute_instruction("10000101");
        check_output(5);
        
        --load -3 into r1
        execute_instruction("10011101");
        check_output(-3);

        --load -1 into r2
        execute_instruction("10101111");
        check_output(-1);

        --load 7 into r3
        execute_instruction("10110111");
        check_output(7);
        
        report "Test 2: Testing addition";
        
        --load 5 into r0
        execute_instruction("10000101");
        check_output(5);
        
        --load 2 into r1
        execute_instruction("10010010");
        check_output(2);
        
        --r0 = r0 + r1 (5 + 2 = 7)
        execute_instruction("00000001");
        check_output(7);

        --r3 = r2 + r1 ((-1) + 7 = 6)
        execute_instruction("00111000");
        check_output(6);

        --load -8 into r0
        execute_instruction("10001000");
        check_output(-8);

        --load -8 into r1
        execute_instruction("10011000");
        check_output(-8);

        --r2 = r0 + r1 ((-1) + (-8) = -16)
        execute_instruction("00100100");
        check_output(-16);
        
        report "Test 3: Testing swap operation";

        --load 4 into r3
        execute_instruction("10110100");
        check_output(4);

        --swap in r3
        execute_instruction("01110000");
        check_output(1024);

        --load -7 into r0
        execute_instruction("10001001");
        check_output(-7);

         --swap in r0 (bit rotation)
        execute_instruction("01000000");
        check_output(-1537);
        
        wait_cycles(10);
        assert false report "End of Tests" severity note;
        wait;
    end process;

end tb;