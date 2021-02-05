# coding:utf-8

class ProgramingError < StandardError; end

class Iroha
  class << self
    def run(src)
      self.new(src).run
    end
  end

  def initialize(src)
    @src = src
    @stack = []
  end

  def run()
    pc = 0
    order = parse()
    labels = find_label(order)
    while order.size > pc
      o, arg = order[pc]
      case o
      when :push
        push(arg)
      when :pop
        pop
      when :dup
        push(@stack[-1])
      when :swap
        y, x = pop, pop
        push(y)
        push(x)
      when :+
        y, x = pop, pop
        push(x + y)
      when :-
        y, x = pop, pop
        push(x - y)
      when :*
        y, x = pop, pop
        push(x * y)
      when :/
        y, x = pop, pop
        push(x / y)
      when :%
        y, x = pop, pop
        push(x % y)
      when :char_in
        push(gets.chomp.ord)
      when :int_in
        push(gets.to_i)
      when :char_out
        print pop.chr("utf-8")
      when :int_out
        print pop
      when :label
      when :jump
        if pop != 0
            pc = labels[arg]
            raise ProgramingError,"ジャンプ先(#{arg.inspect})が見つかりません。"  if pc.nil?
        end
      else
        raise ProgramingError, "そのような命令は存在しません。"
      end
      pc += 1
    end
  end

  def parse
    order = []
    @src.each_line.with_index do |line, i|
      case line.chomp
      when /\Aい+([あ-ん]+)。\z/
        order << [:push, $1.size]
      when /\Aろ+([あ-ん]*)。\z/
        order << [:pop]
      when /\Aは+([あ-ん]*)。\z/
        order << [:dup]
      when /\Aに+([あ-ん]*)。\z/
        order << [:swap]
      when /\Aほ+([あ-ん]*)。\z/
        order << [:+]
      when /\Aへ+([あ-ん]*)。\z/
        order << [:-]
      when /\Aと+([あ-ん]*)。\z/
        order << [:*]
      when /\Aち+([あ-ん]*)。\z/
        order << [:/]
      when /\Aり+([あ-ん]*)。\z/
        order << [:%]
      when /\Aぬ+([あ-ん]*)。\z/
        order << [:char_in]
      when /\Aる+([あ-ん]*)。\z/
        order << [:int_in]
      when /\Aを+([あ-ん]*)。\z/
        order << [:char_out]
      when /\Aわ+([あ-ん]*)。\z/
        order << [:int_out]
      when /\Aゑ+([あ-ん]+)。\z/
        order << [:label, $1]
      when /\Aゐ+([あ-ん]+)。\z/
        order << [:jump, $1]
      when ""
      when /#.*/
      else
        raise ProgramingError, "#{i + 1}行目で構文エラーです。"
      end
    end
    order
  end

  def push(item)
    unless item.is_a?(Integer)
      raise ProgamError, "整数以外(#{item})をプッシュしようとしました。"
    end
    @stack.push(item)
  end

  def pop
    item = @stack.pop
    raise ProgramingError, "空のスタックからポップしようとしました。" if item.nil?
    item
  end

  def find_label(orders)
    labels = {}
    orders.each_with_index do |(order, arg), i|
      raise ProgramingError, "同じラベルは使用できません。" if order == :label && !labels[arg].nil?
      if order == :label
        labels[arg] = i
      end
    end
    labels
  end
end

if $0 == __FILE__
  begin
    Iroha.run(ARGF.read)
  rescue ProgramingError => exception
    puts exception.message
  end
end
