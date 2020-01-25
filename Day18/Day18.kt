import java.io.File

object Main {
    @JvmStatic
    fun main(args: Array<String>) {
        File("input.txt").useLines {
            lines -> lines.forEach {
                var instruction = GetInstruction(it)
                if (instruction != null) {
                    Instructions.Add(instruction)
                }
            }
        }

        while(Sounds.recovered.size == 0 || Sounds.recovered.last() == 0L) {
            Instructions.Execute()
        }
        println("First Non-zero Recovered Sound: ${Sounds.recovered.last()}")

        var program0 = Program("1", "0")
        var program1 = Program("0", "1")

        while(program0.Execute() || program1.Execute()) {
            //Do nothing, either programs are still executing
        }
        println("Program 1 Total Messages (Sent): ${IPC.sent[program1.sendChannel]}")
    }

    @JvmStatic
    fun GetInstruction(instruction: String): Instruction? {
        var parts = instruction.toLowerCase().split(" ")

        return when (parts[0]) {
            "snd" -> Sound(parts[1], Registers)
            "set" -> Set(parts[1], parts[2], Registers)
            "add" -> Add(parts[1], parts[2], Registers)
            "mul" -> Multiply(parts[1], parts[2], Registers)
            "mod" -> Modulo(parts[1], parts[2], Registers)
            "rcv" -> Recover(parts[1], Registers)
            "jgz" -> Jump(parts[1], parts[2], Registers)
            else -> { println("Invalid Instruction: {$instruction}"); return null }
        }
    }
}

class Program: RegisterCollection {
    private var instructions: MutableList<Instruction> = mutableListOf()
    private var registers: MutableMap<String, Register> = mutableMapOf()
    private var index: Long = 0L

    val sendChannel: String
    val receiveChannel: String

    constructor(sendChannel: String, receiveChannel: String) {
        this.sendChannel = sendChannel
        this.receiveChannel = receiveChannel

        File("input.txt").useLines {
                lines -> lines.forEach {
                var instruction = this.GetInstruction(it)
                if (instruction != null) {
                    this.instructions.add(instruction)
                }
            }
        }
        this.Get("p").Set(receiveChannel.toLong())
    }

    fun Execute(): Boolean {
        if (this.instructions.size <= this.index.toInt() || this.index.toInt() < 0) {
            return false
        }
        var instruction = this.instructions[this.index.toInt()]
        var increment = instruction.Execute()
        if (increment == 0L) {
            return false
        }

        this.index += increment
        return true
    }

    override fun Get(value: String): Register {
        return this.registers.getOrPut(value) { Register(value) }
    }


    fun GetInstruction(instruction: String): Instruction? {
        var parts = instruction.toLowerCase().split(" ")

        return when (parts[0]) {
            "snd" -> Send(parts[1], this.sendChannel, this)
            "set" -> Set(parts[1], parts[2], this)
            "add" -> Add(parts[1], parts[2], this)
            "mul" -> Multiply(parts[1], parts[2], this)
            "mod" -> Modulo(parts[1], parts[2], this)
            "rcv" -> Receive(parts[1], this.receiveChannel, this)
            "jgz" -> Jump(parts[1], parts[2], this)
            else -> { println("Invalid Instruction: {$instruction}"); return null }
        }
    }
}

object Instructions {
    private var instructions: MutableList<Instruction> = mutableListOf()
    private var index: Long = 0L

    fun Execute(): Boolean {
        if (this.instructions.size <= this.index.toInt()) {
            return false
        }

        var instruction = this.instructions[index.toInt()]
        this.index += instruction.Execute()
        return true
    }

    fun Add(instruction: Instruction) {
        this.instructions.add(instruction)
    }
}

abstract class Instruction {
    val defaultIncrement: Long = 1L

    abstract fun ToString(): String


    open fun Execute(): Long {
        //println(this.ToString()) <-- Helpful for debugging (prints out the instruction)
        return this.defaultIncrement
    }

    fun GetValue(value: String, registers: RegisterCollection): Value {
        var number = value.toLongOrNull()
        if (number == null) {
            return registers.Get(value)
        }
        return Static(number)
    }
}

class Set: Instruction {
    private val register: Register
    private val value: Value

    constructor(registerName: String, value: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.value = super.GetValue(value, registers)
    }

    override fun Execute(): Long {
        this.register.Set(this.value.Get())
        return super.Execute()
    }

    override fun ToString(): String {
        return "set ${this.register.Name} ${this.value.Get()}"
    }
}

class Add: Instruction {
    private val register: Register
    private val value: Value

    constructor(registerName: String, value: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.value = super.GetValue(value, registers)
    }
    override fun Execute(): Long {
        var newValue = this.register.Get() + this.value.Get()
        this.register.Set(newValue)
        return super.Execute()
    }

    override fun ToString(): String {
        return "add ${this.register.Name} ${this.value.Get()}"
    }
}

class Multiply: Instruction {
    private val register: Register
    private val value: Value

    constructor(registerName: String, value: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.value = super.GetValue(value, registers)
    }

    override fun Execute(): Long {
        var newValue = this.register.Get() * this.value.Get()
        this.register.Set(newValue)
        return super.Execute()
    }

    override fun ToString(): String {
        return "mul ${this.register.Name} ${this.value.Get()}"
    }
}

class Modulo: Instruction {
    private val register: Register
    private val value: Value

    constructor(registerName: String, value: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.value = super.GetValue(value, registers)
    }

    override fun Execute(): Long {
        var newValue = this.register.Get() % this.value.Get()
        this.register.Set(newValue)
        return super.Execute()
    }

    override fun ToString(): String {
        return "mod ${this.register.Name} ${this.value.Get()}"
    }
}

class Recover: Instruction {
    private val register: Register

    constructor(registerName: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
    }

    override fun Execute(): Long {
        if (this.register.Get() != 0L) {
            this.register.Recover()
        }
        return super.Execute()
    }

    override fun ToString(): String {
        return "rcv ${this.register.Name}"
    }
}

class Sound: Instruction {
    private val register: Register

    constructor(registerName: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
    }

    override fun Execute(): Long {
        this.register.Sound()
        return super.Execute()
    }

    override fun ToString(): String {
        return "snd ${this.register.Name}"
    }
}

object IPC {
    var pipe: MutableMap<String, MutableList<Long>> = mutableMapOf()
    var sent: MutableMap<String, Long> = mutableMapOf()
    var received: MutableMap<String, Long> = mutableMapOf()

    fun Receive(channel: String): Pair<Boolean, Long> {
        var queue = this.pipe.getOrPut(channel, { mutableListOf() })
        if (queue.size == 0) {
            return Pair(false, 0L)
        }
        this.received[channel] = this.received.getOrPut(channel, { 0L }) + 1L
        return Pair(true, queue.removeAt(0))
    }

    fun Send(channel: String, value: Long) {
        this.pipe.getOrPut(channel, { mutableListOf() }).add(value)

        this.sent[channel] = this.sent.getOrPut(channel, { 0L }) + 1L
    }
}

class Receive: Instruction {
    private val register: Register
    private val channel: String

    constructor(registerName: String, channel: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.channel = channel
    }

    override fun Execute(): Long {
        var (success, message) = IPC.Receive(this.channel)
        if (!success) {
            return 0L
        }
        this.register.Set(message)
        return super.Execute()
    }

    override fun ToString(): String {
        return "rcv ${this.register.Name}"
    }
}

class Send: Instruction {
    private val register: Register
    private val channel: String


    constructor(registerName: String, channel: String, registers: RegisterCollection) {
        this.register = registers.Get(registerName)
        this.channel = channel
    }

    override fun Execute(): Long {
        this.register.Send(this.channel)
        return super.Execute()
    }

    override fun ToString(): String {
        return "snd ${this.register.Name}"
    }
}

class Jump: Instruction {
    private val register: Value
    private val value: Value

    constructor(registerName: String, value: String, registers: RegisterCollection) {
        this.register = super.GetValue(registerName, registers)
        this.value = super.GetValue(value, registers)
    }

    override fun Execute(): Long {
        if (this.register.Get() > 0L) {
            return this.value.Get()
        }
        return super.Execute()
    }

    override fun ToString(): String {
        return "jgz ${this.register.Get()} ${this.value.Get()}"
    }
}

object Sounds {
    var played: MutableList<Long> = mutableListOf()
    var recovered: MutableList<Long> = mutableListOf()

    fun Recover(value: Long) {
        this.recovered.add(value)
    }

    fun Play(value: Long) {
        this.played.add(value)
    }
}


interface RegisterCollection {
    fun Get(value: String): Register
}

object Registers: RegisterCollection {
    private var registers: MutableMap<String, Register> = mutableMapOf()

    override fun Get(value: String): Register {
        return this.registers.getOrPut(value) { Register(value) }
    }
}

interface Value {
    fun Get(): Long
}

class Static: Value {
    private var Value: Long

    constructor(value: Long) {
        this.Value = value
    }

    override fun Get(): Long  {
        return this.Value
    }
}

class Register: Value {
    val Name: String
    var value: Long
    var lastSound: Long

    constructor(name: String) {
        this.Name = name
        this.value = 0L
        this.lastSound = this.value
    }

    fun Set(value: Long) {
        this.value = value
    }

    fun Sound() {
        Sounds.Play(this.value)
        this.lastSound = this.value
    }

    fun Recover() {
        if (this.value != 0L) {
            Sounds.Recover(this.lastSound)
        }
    }

    fun Send(channel: String) {
        IPC.Send(channel, this.Get())
    }

    override fun Get(): Long {
        return this.value
    }
}
