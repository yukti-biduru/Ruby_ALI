# Hardware class containing the memory items of the application - registers, bits, symbol arrays memory
# and memory pointer
class Hardware
  #getter setters
  attr_accessor :program_counter, :register_a, :register_b, :memory, :zero_result_bit, :overflow_bit,
                :symbol_array, :memory_ptr

  #initialization
  def initialize
    @program_counter = 0
    @register_a = 0
    @register_b = 0
    @memory = []
    @zero_result_bit = 0
    @overflow_bit = 0
    @symbol_array = Hash.new
    @memory_ptr = 127 #since pointer is being used for storing program data
  end

  #get next available memory space
  def get_next_empty_memory_space
    if @memory_ptr == 127 && memory.length>127
      @memory_ptr = memory.length
    else
      @memory_ptr += 1
    end

    return @memory_ptr
  end

  # method to print output for the hardware items
  def print_output
    puts "Accumulator = #{@register_a}"
    puts "Additional Register = #{@register_b}"
    puts "Program Counter = #{@program_counter}"
    puts "Zero Result Bit = #{@zero_result_bit}"
    puts "Overflow Bit = #{@overflow_bit}"
    puts
    puts "Symbols and their values"
    @symbol_array.each { |x,y| puts "Key = #{x}, Value = #{y}"}
    puts
    puts "Memory"
    @memory.each { |x| puts x unless x == nil }
    puts
    end
  end


# Instruction super class
# for defining the working of the instructions
class Instructions
  #getter setter
  attr_accessor :Opcode,:ArgType, :Arg, :hardware
  def initialize (_hardware, argument)
    @hardware = _hardware
  end

  #execute abstract function
  def execute
  end

  # function for instruction switch case to execute subclass functions
  def instruction_execution (instruction_string)
    command = instruction_string.split(" ")
    instruction = command[0]
    argument = command[1]

    case instruction
    when "DEC"
      @Opcode = "DEC"
      @ArgType = "STRING"
      dec = DEC.new(@hardware, argument)
      dec.execute
    when "LDA"
      @Opcode = "LDA"
      @ArgType = "STRING"
      lda = LDA.new(@hardware, argument)
      lda.execute
    when "LDB"
      @Opcode = "LDB"
      @ArgType = "STRING"
      ldb = LDB.new(@hardware, argument)
      ldb.execute
    when "LDI"
      @Opcode = "LDI"
      @ArgType = "NUMBER"
      ldi = LDI.new(@hardware, argument)
      ldi.execute
    when "STR"
      @Opcode = "STR"
      @ArgType = "STRING"
      str = STR.new(@hardware, argument)
      str.execute
    when "XCH"
      @Opcode = "XCH"
      @ArgType = "NONE"
      xch = XCH.new(@hardware, argument)
      xch.execute
    when "JMP"
      @Opcode = "JMP"
      @ArgType = "NUMBER"
      jmp = JMP.new(@hardware, argument)
      jmp.execute
    when "JZS"
      @Opcode = "JZS"
      @ArgType = "NUMBER"
      jzs = JZS.new(@hardware, argument)
      jzs.execute
    when "JVS"
      @Opcode = "JVS"
      @ArgType = "NUMBER"
      jvs = JVS.new(@hardware, argument)
      jvs.execute
    when "ADD"
      @Opcode = "ADD"
      @ArgType = "NONE"
      add =ADD.new(@hardware, argument)
      add.execute
    when "HLT"
      @Opcode = "HLT"
      @ArgType = "NONE"
    end
  end
end


# Instruction sub classes
# each instruction has its own sub class and it uses the hardware instance to manipulate data
# each subclass defines the abstract execute method thus using inheritance
class DEC < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    if @hardware.symbol_array == nil
      @hardware.symbol_array = Hash.new
    else
      available_memory_space = @hardware.get_next_empty_memory_space
      @hardware.symbol_array.store(@Arg, available_memory_space)

    end
  end

end

class LDA < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    memory_location = @hardware.symbol_array.fetch(@Arg)
    @hardware.register_a = @hardware.memory[memory_location]
  end
end

class LDB < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    memory_location = @hardware.symbol_array[@Arg]
    @hardware.register_b = @hardware.memory[memory_location]
  end
end

class LDI < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    @hardware.register_a = @Arg
  end
end

class STR < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    memory_location = @hardware.symbol_array[@Arg]
    @hardware.memory[memory_location] = @hardware.register_a
  end
end

class XCH < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    temp = @hardware.register_a
    @hardware.register_a = @hardware.register_b
    @hardware.register_b = temp
  end
end

class JMP < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end
  def execute
    @hardware.program_counter = @Arg.to_i
  end
end

class JZS < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    if @hardware.zero_result_bit == 1
      @hardware.program_counter = @Arg.to_i
    end
  end
end

class JVS < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
    @Arg = argument
  end

  def execute
    if @hardware.overflow_bit == 1
      @hardware.program_counter = @Arg.to_i
    end
  end
end

class ADD < Instructions
  attr_accessor :hardware
  def initialize(hardware, argument)
    @hardware = hardware
  end
  def execute
    @hardware.register_a = @hardware.register_a.to_i + @hardware.register_b.to_i
    if @hardware.register_a.to_i == 0
      @hardware.zero_result_bit = 1
    end
    if @hardware.register_a.to_i > 2147483647 || @hardware.register_a.to_i < -2147483648
      @hardware.overflow_bit = 1 #TODO check values of all the registers and the program counter in get and set methods
    end
  end
end

#input file name
while(true)
  puts "Please enter the filename to be used."
  user_input = gets.chomp.split(/[.]/)
  aFile = File.new(user_input[0]+".txt", "r+")
  if !File::exists?aFile
    puts "File doesn't exist. Please enter another file."

  elsif (arr = IO.readlines(aFile))
    if arr[0]==nil
      puts "File has no data. Please enter another file."
    end
  end
  break
end

#initialize hardware and instruction classes
hardware = Hardware.new
hardware.memory = arr
instr = Instructions.new(hardware,nil)

#commad loop for instructions
user_input_command = ""
while user_input_command != "q"
  puts "Please enter command"
  user_input_command = gets.chomp

  case (user_input_command)
  when "s" # single line
    value = instr.hardware.memory[instr.hardware.program_counter]
    if value == nil
      break
      end
    instr.instruction_execution(value)
    instr.hardware.print_output
    instr.hardware.program_counter += 1
    puts instr.hardware.memory[instr.hardware.program_counter]
    if instr.Opcode == "HLT"
      break
    end
  when "a" # all lines
    instruction_count = 1
    while instruction_count != 1000
      value = instr.hardware.memory[instr.hardware.program_counter]
      if value == nil
        break
      end
      instr.instruction_execution(value)
      instr.hardware.program_counter += 1
      if instr.Opcode == "HLT"
        break
      end
    end
    instr.hardware.print_output
    break
  when "q" #quit
    break
  end

end

