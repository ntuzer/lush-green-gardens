require_relative 'font.rb'

font_letters = {
  :A => A, :B => B, :C => C,
  :D => D, :E => E, :F => F,
  :G => G, :H => H, :I => I,
  :J => J, :K => K, :L => L,
  :M => M, :N => N, :O => O,
  :P => P, :Q => Q, :R => R,
  :S => S, :T => T, :U => U,
  :V => V, :W => W, :X => X,
  :Y => Y, :Z => Z
}

mapping = {
  '0' => 2,
  '1' => 3,
  '2' => 0,
  '3' => 1,
}

fl = File.open('output.txt','a')



font_letters.each do |k,v|
  temp = v
  # temp.each_with_index { |c, i| temp[i] = mapping[c.to_s]}


  fl.write("#{k} = [\n")
  str = ""
  temp.each_with_index do |l, i|
    if (i+1) == temp.length
      str += ",#{l}\n"
      fl.write(str)
      str = ""
    elsif (i+1) % 7 == 0
      str += ",#{l},\n"
      fl.write(str)
      str = ""
    elsif (i+1) % 7 == 1
      str += "    #{l}"
    else
      str += ",#{l}"
    end
  end
  fl.write("]\n")

end





fl.close
