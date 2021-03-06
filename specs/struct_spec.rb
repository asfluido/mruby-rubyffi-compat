module FFITests
  module TestLib
    class S1Struct < FFI::Struct
      layout(
          :n1,  :uint32,
          :n2,  :uint32,
          :s1,  :uint16,
          :d1,  :double,
        )
    end
    
    class BufferStruct < FFI::Struct 
      layout(
          :id,    :uint8, 
          :name,  [:uint8, 7]
        )
    end 
    
    attach_function :fill_struct, [:pointer], :void
    attach_function :create_buffer, [], :pointer
    attach_function :inspect_buffer, [:pointer], :void
  end
end


header "Structures tests"


should 'fill structure' do
  s = FFITests::TestLib::S1Struct.new
  FFITests::TestLib.fill_struct(s.addr)
  
  eq(56,    s[:n1])
  eq(982,   s[:n2])
  eq(12,    s[:s1])
  eq(6.78,  s[:d1])
end

bs = nil

should 'have buffer of `rambo !`' do
  bs_value = FFITests::TestLib::create_buffer
  bs = FFITests::TestLib::BufferStruct.new(bs_value)
  eq "rambo !",bs[:name].to_s 
end

should "behave like array" do
  chars = [114,97,109,98,111,32,33]
  chars.each_with_index do |c,i|
    eq c,bs[:name][i]
  end
  eq chars,bs[:name].to_a
end

chars = [65,66,67,68,69,70,71]

should 'be overwritten' do
  chars.each_with_index do |c,i|
    bs[:name][i] = c    
  end
  eq "ABCDEFG",bs[:name].to_s
end

should 'become array' do
  eq chars,bs[:name].to_a 
end

# should 'allow direct access to buffer characters' do
#   s_ptr = FFITests::TestLib.create_buffer()
#   s = FFITests::TestLib::BufferStruct.new(s_ptr)
#   s[:name][0] = "o".bytes[0] # set a single byte within the struct
#   eq("oambo !", s[:name].to_ptr.read_string())
# end
