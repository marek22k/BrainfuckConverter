
class BrainfuckConverter
  
  DEFAULT_COMMANDS = {
    inc_val: "+",
    dec_val: "-",
    inc_ptr: ">",
    dec_ptr: "<",
    output: ".",
    loop_begin: "[",
    loop_end: "]"
  }
  
  attr_reader :code
  attr_accessor :cmds
  
  # Initializes a new Brainfuck Converter
  #
  # @param bf_cmds [Hash] Command sign. If not specified, the default command
  #   set under BrainfuckConverter::DEFAULT_COMMANDS will be used.
  def initialize bf_cmds = DEFAULT_COMMANDS
    @cmds = bf_cmds
  end
  
  # Converts an ASCII string to Brainfuck code.
  #
  # @param text [String] The text to be converted into Brainfuck code.
  # @param cells_num [Integer] Number of cells to be used. All values from 0
  #   can be used. If not specified, 8 cells are used. Regardless of the number
  #   specified here, an additional cell is used.
  # @return [String, FalseClass]
  # @example
  #   require "brainfuck_converter"
  #   
  #   con = BrainfuckConverter.new
  #   
  #   con.convert "Hello World!"  # => "Hello World!"
  #   con.code  # => "++++++++++++++[>+>++>+++>++++>+++++>++++++>++++++... too long"
  #   
  #   con.convert "Hallo Welt!", 15  # => "Hallo Welt!"
  #   con.code  # => "+++++++[>+>++>+++>++++>+++++>++++++>+++++++>+++++... too long"
  def convert text, cells_num = 8
    # To output a string in Brainfuck, "auxiliary numbers" are written into
    # certain cells. If a letter is to be output, the letter is converted into
    # an ASCII value and the auxiliary number that is closest to it is searched for.
    # This is then adjusted so that it corresponds to the ASCII value of the letter.
    # The auxiliary number or the letter is then output.
    
    if cells_num < 1
      return false
    end
    
    # Code is cleared. A new Brainfuck program is started.
    @code = ""
    
    # Calculating the auxiliary numbers
    space_cells = 127 / (cells_num + 1)
    @cell_values = []
    @cell_values[0] = space_cells
    for i in 1...cells_num
      @cell_values[i] = @cell_values[i - 1] + space_cells
    end

    # The code to create the auxiliary numbers in the cells is created.
    # The auxiliary numbers are created by multiplication.
    # This also has the advantage that you can use a loop.
    @code += @cmds[:inc_val] * space_cells
    @code += @cmds[:loop_begin]
    for i in 1..cells_num
      @code += @cmds[:inc_ptr]
      @code += @cmds[:inc_val] * i
    end
    @code += @cmds[:dec_ptr] * cells_num
    @code += @cmds[:dec_val]
    @code += @cmds[:loop_end]
    @code += @cmds[:inc_ptr]

    # A pointer to get to the corresponding cells later.
    # To be exact, you would be at cell 1, but you can ignore the first cell 0,
    # because it was only used as a counter for the loop.
    @pointer = 0

    text.each_byte { |search|
      # Search for the next auxiliary number
      diffs = @cell_values.map { |val|
        (search - val).abs
      }
      nearest = diffs.index(diffs.min)
      diff = search - @cell_values[nearest]

      # It goes to the auxiliary number. This is changed accordingly and the
      # corresponding ASCII_character is output.
      move_pointer @pointer, nearest
      change_value search
      output_cell
    }
  end
  
  protected
  
  def move_pointer cur_pos, target_pos
    move = target_pos - cur_pos
    @code += (move < 0 ? @cmds[:dec_ptr] : @cmds[:inc_ptr]) * move.abs 
    @pointer = target_pos
  end

  def change_value target_value
    change = target_value - @cell_values[@pointer]
    @code += (change < 0 ? @cmds[:dec_val] : @cmds[:inc_val]) * change.abs
    @cell_values[@pointer] = target_value
  end

  def output_cell
    @code += @cmds[:output]
  end
  
end
