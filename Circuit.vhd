library ieee;
use ieee.std_logic_1164.all;

entity Circuit is
    port (
        Clock: in std_logic;
        Input1, Input2: in std_logic_vector(15 downto 0);
        Operation: in std_logic_vector(2 downto 0);
        ALUout: out std_logic_vector(15 downto 0);
        FlipFlopOut: out std_logic_vector(15 downto 0);
		  FlipFlop1Out, FlipFlop2Out: out std_logic_vector(15 downto 0)
    );
end Circuit;

architecture structural of Circuit is
    component reg is
        port (
            Clock, Enable: in std_logic;
            Input: in std_logic_vector(15 downto 0);
            Output: out std_logic_vector(15 downto 0)
        );
    end component;

    component ALU is
        port (
            A, B: in std_logic_vector(15 downto 0);
            Op: in std_logic_vector(2 downto 0);
            Output: out std_logic_vector(15 downto 0);
			   Overflow: out std_logic
        );
    end component;

    signal Reg1Out, Reg2Out: std_logic_vector(15 downto 0);
    signal ALUOutputA: std_logic_vector(15 downto 0);
    signal FlipFlopIn: std_logic_vector(15 downto 0);
	 signal OverflowA: std_logic;
	 

begin

    -- two flip-flops
    FF1: reg port map (
        Clock => Clock,
        Enable => '1',
        Input => Input1,
        Output => Reg1Out
    );

    FF2: reg port map (
        Clock => Clock,
        Enable => '1',
        Input => Input2,
        Output => Reg2Out
    );

    --  ALU
    ALUA: ALU port map (
        A => Reg1Out,
        B => Reg2Out,
        Op => Operation,
        Output => ALUOutputA,
		Overflow => OverflowA
    );

    -- flip-flop for the ALU output
    FF3: reg port map (
        Clock => Clock,
        Enable => '1',
        Input => ALUOutputA,
        Output => FlipFlopIn
    );

    ALUout <= ALUOutputA;
    FlipFlopOut <= FlipFlopIn;
	 FlipFlop1Out <= Reg1Out;
	 FlipFlop2Out <= Reg2Out;
end structural;

-- ALU starts here -- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        A, B: in std_logic_vector(15 downto 0);
        Op: in std_logic_vector(2 downto 0);
        Output: out std_logic_vector(15 downto 0);
        Overflow: out std_logic
    );
end ALU;

architecture structural of ALU is
    component Add_Sub_Component is
        port (
            Input1, Input2: in std_logic_vector(15 downto 0);
            Cin: in std_logic;
            Output: out std_logic_vector(15 downto 0);
            Cout: out std_logic
        );
    end component;

    component Comparator_Component is
        port (
            Input1: in std_logic_vector(15 downto 0);
            Output: out std_logic_vector(15 downto 0)
        );
    end component;

    component Logical_Operator_Component is
        port (
            Input1, Input2: in std_logic_vector(15 downto 0);
            Operation: in std_logic_vector(2 downto 0);
            Output: out std_logic_vector(15 downto 0)
        );
    end component;

    component Not_Component is
        port (
            Input1: in std_logic_vector(15 downto 0);
            Output: out std_logic_vector(15 downto 0)
        );
    end component;

    signal Add_Sub_Output: std_logic_vector(15 downto 0);
    signal Add_Sub_Cout: std_logic;
    signal Comparator_Component_GEQ: std_logic_vector(15 downto 0);
    signal Logical_Operator_Component_Output: std_logic_vector(15 downto 0);
    signal Not_Component_Output: std_logic_vector(15 downto 0);

begin

    Add_Sub: Add_Sub_Component port map (
        Input1 => A,
        Input2 => B,
        Cin => Op(0),
        Output => Add_Sub_Output,
        Cout => Add_Sub_Cout
    );

    Comp: Comparator_Component port map (
        Input1 => A,
		  Output => Comparator_Component_GEQ
    );

    Logic_Op: Logical_Operator_Component port map (
        Input1 => A,
        Input2 => B,
        Operation => Op,
        Output => Logical_Operator_Component_Output
    );

    Not_1: Not_Component port map (
        Input1 => A,
        Output => Not_Component_Output
    );

    with Op select
        Output <= Add_Sub_Output when "000",
                  std_logic_vector(unsigned(A) - unsigned(B)) when "001",
                  Logical_Operator_Component_Output when "010" | "011" | "110" | "111",
                  Not_Component_Output when "101",
						Comparator_Component_GEQ when "100",
                  (others => '0') when others;

    Overflow <= Add_Sub_Cout;

end structural;

library ieee;
use ieee.std_logic_1164.all;

entity Comparator_Component is
    port (
        Input1: in std_logic_vector(15 downto 0);
        Output: out std_logic_vector(15 downto 0)
    );
end Comparator_Component;

architecture structural of Comparator_Component is
begin
    process (Input1)
    begin
        if Input1(15) = '0' then
            Output <= "0000000000000001";  
        else
            Output <= "0000000000000000";  
        end if;
    end process;
end structural;

library ieee;
use ieee.std_logic_1164.all;

entity Not_Component is
    port (
        Input1: in std_logic_vector(15 downto 0);
        Output: out std_logic_vector(15 downto 0)
    );
end Not_Component;

architecture structural of Not_Component is
begin
    process (Input1)
    begin
        if Input1 = "0000000000000000" then
            Output <= "0000000000000001";  
        else
            Output <= "0000000000000000";  
        end if;
    end process;
end structural;

library ieee;
use ieee.std_logic_1164.all;

entity Logical_Operator_Component is
    port (
        Input1, Input2: in std_logic_vector(15 downto 0);
        Operation: in std_logic_vector(2 downto 0);
        Output: out std_logic_vector(15 downto 0)
    );
end Logical_Operator_Component;

architecture structural of Logical_Operator_Component is

    component myAND
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    component myOR
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    component myXOR
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    component myNOR
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    signal AND_out, OR_out, XOR_out, NOR_out: std_logic_vector(15 downto 0);
    signal temp: std_logic_vector(15 downto 0);

begin

    AND_loop: for i in 0 to 15 generate
        AND_comp: myAND port map (
            in1 => Input1(i),
            in2 => Input2(i),
            out1 => AND_out(i)
        );
    end generate AND_loop;

    OR_loop: for i in 0 to 15 generate
        OR_comp: myOR port map (
            in1 => Input1(i),
            in2 => Input2(i),
            out1 => OR_out(i)
        );
    end generate OR_loop;

    XOR_loop: for i in 0 to 15 generate
        XOR_comp: myXOR port map (
            in1 => Input1(i),
            in2 => Input2(i),
            out1 => XOR_out(i)
        );
    end generate XOR_loop;

    NOR_loop: for i in 0 to 15 generate
        NOR_comp: myNOR port map (
            in1 => Input1(i),
            in2 => Input2(i),
            out1 => NOR_out(i)
        );
    end generate NOR_loop;

    process (Operation, AND_out, OR_out, XOR_out, NOR_out)
    begin
        for i in 0 to 15 loop
            case Operation is
                when "010" =>
                    temp(i) <= AND_out(i);
                when "011" =>
                    temp(i) <= OR_out(i);
                when "110" =>
                    temp(i) <= XOR_out(i);
                when "111" =>
                    temp(i) <= NOR_out(i);
                when others =>
                    temp(i) <= '0';
            end case;
        end loop;
        
        Output <= temp;
    end process;

end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity Add_Sub_Component is
port(
		Input1,Input2 : in std_logic_vector(15 downto 0);
		cin : in std_logic;
		Output : out std_logic_vector(15 downto 0);
		Cout : out std_logic
	  );
end Add_Sub_Component;

architecture Fa_Arch of Add_Sub_Component is
signal cary : std_logic_vector(14 downto 0);

component Full_Adder is
  port (p,q,r:in std_logic; sm,cr: out std_logic);
end component;
  begin
     a0:Full_Adder port map (Input1(0),Input2(0),cin,Output(0),cary(0));
     a1:Full_Adder port map (Input1(1),Input2(1),cary(0),Output(1),cary(1));
     a2:Full_Adder port map (Input1(2),Input2(2),cary(1),Output(2),cary(2));
     a3:Full_Adder port map (Input1(3),Input2(3),cary(2),Output(3),cary(3));
     a4:Full_Adder port map (Input1(4),Input2(4),cary(3),Output(4),cary(4));
     a5:Full_Adder port map (Input1(5),Input2(5),cary(4),Output(5),cary(5));
     a6:Full_Adder port map (Input1(6),Input2(6),cary(5),Output(6),cary(6));
     a7:Full_Adder port map (Input1(7),Input2(7),cary(6),Output(7),cary(7));
     a8:Full_Adder port map (Input1(8),Input2(8),cary(7),Output(8),cary(8));
     a9:Full_Adder port map (Input1(9),Input2(9),cary(8),Output(9),cary(9));
     a10:Full_Adder port map (Input1(10),Input2(10),cary(9),Output(10),cary(10));
     a11:Full_Adder port map (Input1(11),Input2(11),cary(10),Output(11),cary(11));
     a12:Full_Adder port map (Input1(12),Input2(12),cary(11),Output(12),cary(12));
     a13:Full_Adder port map (Input1(13),Input2(13),cary(12),Output(13),cary(13));
     a14:Full_Adder port map (Input1(14),Input2(14),cary(13),Output(14),cary(14));
     a15:Full_Adder port map (Input1(15),Input2(15),cary(14),Output(15),Cout);
end Fa_Arch;

library ieee;
use ieee.std_logic_1164.all;
entity Full_Adder is
   port (p,q,r:in std_logic; sm,cr: out std_logic);
end Full_Adder;

architecture Fa_Arc of Full_Adder is
    component myXOR is
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    component myAND is
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    component myOR is
        port (
            in1, in2: in std_logic;
            out1: out std_logic
        );
    end component;

    signal sm_inter, and_inter1, and_inter2, and_inter3, or_inter1: std_logic;

begin
    XOR1: myXOR port map (p, q, sm_inter);
    XOR2: myXOR port map (sm_inter, r, sm);

    AND1: myAND port map (p, q, and_inter1);
    AND2: myAND port map (q, r, and_inter2);
    AND3: myAND port map (r, p, and_inter3);

    OR1: myOR port map (and_inter1, and_inter2, or_inter1);
    OR2: myOR port map (or_inter1, and_inter3, cr);
end Fa_Arc;
--myGates--

library ieee;
use ieee.std_logic_1164.all;

entity myOR is
    port (
        in1, in2: in std_logic;
        out1: out std_logic
    );
end myOR;

architecture OR_LogicFunc of myOR is
begin
    out1 <= in1 OR in2;
end OR_LogicFunc;

library ieee;
use ieee.std_logic_1164.all;

entity myXOR is
    port (
        in1, in2: in std_logic;
        out1: out std_logic
    );
end myXOR;

architecture XOR_LogicFunc of myXOR is
begin
    out1 <= in1 XOR in2;
end XOR_LogicFunc;

library ieee;
use ieee.std_logic_1164.all;

entity myNOR is
    port (
        in1, in2: in std_logic;
        out1: out std_logic
    );
end myNOR;

architecture NOR_LogicFunc of myNOR is
begin
    out1 <= not (in1 OR in2);
end NOR_LogicFunc;

library ieee;
use ieee.std_logic_1164.all;

entity myAND is
port(in1, in2: in std_logic; 
           out1: out std_logic);
end myAND;

architecture AND_LogicFunc of myAND is
begin
           out1 <= in1 AND in2;
end AND_LogicFunc;

-- Flip Flop starts here --

library ieee;
use ieee.std_logic_1164.all;

entity reg is
    port (
        Clock, Enable: in std_logic;
        Input: in std_logic_vector(15 downto 0);
        Output: out std_logic_vector(15 downto 0)
    );
end reg;

architecture structural of reg is
    component D_Flip_Flop_Component is
        port (
            Clock, Enable, D: in std_logic;
            Q: out std_logic
        );
    end component;

    signal Q: std_logic_vector(15 downto 0);
    signal D: std_logic_vector(15 downto 0);

begin

    D <= Input when Enable = '1' else (others => '0');

    FF0: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(0),
        Q => Q(0)
    );

    FF1: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(1),
        Q => Q(1)
    );
	
	FF2: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(2),
        Q => Q(2)
    );
	
	FF3: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(3),
        Q => Q(3)
    );
	
	FF4: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(4),
        Q => Q(4)
    );
	
	FF5: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(5),
        Q => Q(5)
    );
	
	FF6: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(6),
        Q => Q(6)
    );
	
	FF7: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(7),
        Q => Q(7)
    );
	
	FF8: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(8),
        Q => Q(8)
    );
	
	FF9: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(9),
        Q => Q(9)
    );
	
	FF10: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(10),
        Q => Q(10)
    );
	
	FF11: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(11),
        Q => Q(11)
    );
	
	FF12: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(12),
        Q => Q(12)
    );
	
	FF13: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(13),
        Q => Q(13)
    );
	
	FF14: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(14),
        Q => Q(14)
    );
	
	FF15: D_Flip_Flop_Component port map (
        Clock => Clock,
        Enable => Enable,
        D => D(15),
        Q => Q(15)
    );

    Output <= Q;

end structural;


library ieee;
use ieee.std_logic_1164.all;

entity D_Flip_Flop_Component is
    port (
        Clock, Enable, D: in std_logic;
        Q: out std_logic
    );
end D_Flip_Flop_Component;

architecture gate of D_Flip_Flop_Component is
begin
    process (Clock, Enable)
    begin
        if Enable = '0' then
            Q <= '0';
        elsif rising_edge(Clock) then
            Q <= D;
        end if;
    end process;
end gate;
