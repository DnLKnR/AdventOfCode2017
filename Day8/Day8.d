module runnable;

import std.stdio;
import std.string;
import std.conv;
import std.getopt;
import std.format;

string filename = "input.txt";

void main(string[] args)
{
    //check command line arguments for filename (use input.txt if not specified)
    auto info = getopt(args, "file", "Specify file that contains input data", &filename);
    if (info.helpWanted)
    {
        defaultGetoptPrinter("This program solves Day 8 of Advent Of Code 2017", info.options);
        return;
    }
    //get the file and iterator for each line
    auto file = File(filename);
    auto range = file.byLine();

    //instantiate our registers that will store our values
    Registers registers = new Registers();

    //parse each line of the input into an instruction
    //and execute that instruction on our registers
    foreach (line; range)
    {
        Instruction instruction = Parser.GetInstruction(line.dup);
        registers.Execute(instruction);
    }
    //get the current max value in the registers after executing all the lines
    Register maxRegister = registers.GetMax();
    writeln(format("Max (Value): %s", maxRegister.ToString()));

    //get the max allocated register
    Register maxAllocatedRegister = registers.GetMaxAllocated();
    writeln(format("Max (Allocated): %s", maxAllocatedRegister.ToString()));
}

/+++++++++++++++++++++++++++++++++++++++
 + The Registers class contains all the
 + registers, keyed by their name.
 +
 + Registers can be used to execute instructions,
 + which will update the registers accordingly.
 +/
public class Registers
{
    private static const int DEFAULT_VALUE = 0;

    private Register[string] registers;

    /*********************************
     * Perform an instruction on the registers, updating them
     */
    public void Execute(Instruction instruction)
    {
        //check if the condition is true
        int conditionValue = this.Get(instruction.Condition.Key).Value;
        bool condition = instruction.Condition.Execute(conditionValue);

        if (condition)
        {
            Register current = this.Get(instruction.Operation.Key);
            int newValue = instruction.Operation.Execute(current.Value);
            this.Set(instruction.Operation.Key, newValue);
        }
    }

    /*********************************
     * Safely gets a register by key from the registers
     */
    private Register Get(string key)
    {
        if (!this.registers.get(key, null))
        {
            this.Set(key, DEFAULT_VALUE);
        }
        return this.registers[key];
    }

    /*********************************
     * Safely set a registerto value by key
     * (without overwriting a register)
     */
    private void Set(string key, int value)
    {
        //check if key doesnt have a register
        if (!this.registers.get(key, null))
        {
            //instantiate the register since it doesnt exist
            this.registers[key] = new Register(key, value);
        }
        else
        {
            //update the register's value since it already exists
            this.registers[key].Update(value);
        }
    }

    /*********************************
     * Find the first register that currently has the highest value
     */
    public Register GetMax()
    {
        immutable string firstKey = this.registers.keys[DEFAULT_VALUE];
        Register maxRegister = this.registers[firstKey];
        foreach (key; this.registers.byKey)
        {
            Register register = this.registers[key];
            if (register.Value > maxRegister.Value)
            {
                maxRegister = register;
            }
        }
        return maxRegister;
    }

    /*********************************
     * Find the first register that has the highest allocation
     */
    public Register GetMaxAllocated()
    {
        immutable string firstKey = this.registers.keys[DEFAULT_VALUE];
        Register maxAllocatedRegister = this.registers[firstKey];
        foreach (key; this.registers.byKey)
        {
            Register register = this.registers[key];
            if (register.Allocated > maxAllocatedRegister.Allocated)
            {
                maxAllocatedRegister = register;
            }
        }
        return maxAllocatedRegister;
    }
}

/+++++++++++++++++++++++++++++++++++++++
 + The Register class contains information
 + about a register.  Its name, current value,
 + and space allocated for it.
 +
 + (Values require allocation, which the registers
 + do not free up when a lower value is introduced)
 +/
public class Register
{
    public immutable string Name;
    public int Value;
    public int Allocated;

    public this(string name, int value)
    {
        this.Name = name;
        this.Value = value;
        this.Allocated = value;
    }

    /*********************************
     * Update this register with a new value
     */
    public void Update(int value)
    {
        this.Value = value;

        //if the new value is higher than the registers allocation,
        //increase the registers allocated memory
        if (value > this.Allocated)
        {
            this.Allocated = value;
        }
    }

    /*********************************
     * Convert this Register into a human-readable string
     */
    public string ToString()
    {
        return format("%s (Value = %d, Allocated = %d)", this.Name, this.Value, this.Allocated);
    }
}

/+++++++++++++++++++++++++++++++++++++++
 + The Instruction class pairs an Operation with a condition.
 +/
public class Instruction
{
    public Operational Operation;
    public Conditional Condition;

    public this(Operational operation, Conditional condition)
    {
        this.Operation = operation;
        this.Condition = condition;
    }
}

/+++++++++++++++++++++++++++++++++++++++
 + The Operational class stores an operation that can be
 + executed on a given input.
 +/
public class Operational
{
    private static const string INCREMENT = "inc";
    private static const string DECREMENT = "dec";

    public immutable string Key;
    public immutable int delegate(int value) Execute;

    public this(string key, string operator, int value)
    {
        this.Key = key;
        this.Execute = this.GetOperation(operator, value);
    }

    /*********************************
     * Brute force function that creates a function
     * based on such: '(int x) => x operator value'
     * where operator is a relational operator (<, >, ==, etc)
     */
    private int delegate(int) GetOperation(string operator, int value)
    {
        switch (operator)
        {
            case INCREMENT:
                return (int x) => x + value;
            case DECREMENT:
            default:
                return (int x) => x - value;
        }
    }
}

/+++++++++++++++++++++++++++++++++++++++
 + The Conditional class stores a condition
 + operator that evaluates a given input.
 +/
public class Conditional
{
    private static const string EQUIVALENT = "==";
    private static const string NOT_EQUIVALENT = "!=";
    private static const string GREATER = ">";
    private static const string GREATER_OR_EQUAL = ">=";
    private static const string LESSER = "<";
    private static const string LESSER_OR_EQUAL = "<=";

    public immutable string Key;
    public immutable bool delegate(int value) Execute;

    public this(string key, string operator, int value)
    {
        this.Key = key;
        this.Execute = this.GetOperation(operator, value);
    }

    /*********************************
     * Brute force function that creates a function
     * based on such: '(int x) => x operator value'
     * where operator is a relational operator (<, >, ==, etc)
     */
    public bool delegate(int) GetOperation(string operator, int value)
    {
        switch (operator)
        {
            case EQUIVALENT:
                return (int x) => x == value;
            case NOT_EQUIVALENT:
                return (int x) => x != value;
            case GREATER:
                return (int x) => x > value;
            case GREATER_OR_EQUAL:
                return (int x) => x >= value;
            case LESSER:
                return (int x) => x < value;
            case LESSER_OR_EQUAL:
            default:
                return (int x) => x <= value;
        }
    }
}

/+++++++++++++++++++++++++++++++++++++++
 + The Parser class is used to parse the
 + input lines into instructions for the
 + the registers.
 +/
public static class Parser
{
    private static const int KEY_INDEX = 0;
    private static const int OPERATOR_INDEX = 1;
    private static const int VALUE_INDEX = 2;

    private static const int OPERATION_INDEX = 0;
    private static const int CONDITION_INDEX = 1;

    private static const string SEPARATOR = " if ";
    private static const string SPACE = " ";

    /*********************************
     * Parses input (like -> "xn dec -181 if cp >= -4748")
     * into an instruction that can be executed on the registers.
     */
    public static GetInstruction(string line)
    {
        string[] parts = line.split(SEPARATOR);

        Operational operation = Parser.GetOperation(parts[OPERATION_INDEX]);
        Conditional condition = Parser.GetCondition(parts[CONDITION_INDEX]);

        return new Instruction(operation, condition);
    }

    /*********************************
     * Parses operation input (like -> xn dec -181)
     * into an operation that can be executed on a register
     */
    private static Operational GetOperation(string operationLine)
    {
        string[] parts = operationLine.split(SPACE);
        auto key = parts[KEY_INDEX];
        auto operator = parts[OPERATOR_INDEX];
        immutable int value = to!int(parts[VALUE_INDEX]);
        return new Operational(key, operator, value);
    }

    /*********************************
     * Parses condition input (like -> xcp >= -4748")
     * into an operation that can be executed on a register
     */
    private static Conditional GetCondition(string conditionLine)
    {
        string[] parts = conditionLine.split(SPACE);
        auto key = parts[KEY_INDEX];
        auto operator = parts[OPERATOR_INDEX];
        immutable int value = to!int(parts[VALUE_INDEX]);
        return new Conditional(key, operator, value);
    }
}
