require 'test/unit'
require 'log4r'

module Log4r

class TestFormatter < Test::Unit::TestCase
  def test_creation
    assert_no_exception { Formatter.new.format(3) }
    assert_no_exception { DefaultFormatter.new }
    assert_kind_of(Formatter, DefaultFormatter.new)
  end
  def test_simple_formatter
    sf = SimpleFormatter.new
    f = Logger.new('simple formatter')
    event = LogEvent.new(0, f, nil, "some data")
    assert_match(sf.format(event), /simple formatter/)
  end
  def test_basic_formatter
    b = BasicFormatter.new
    f = Logger.new('fake formatter')
    event = LogEvent.new(0, f, caller, "fake formatter")
    event2 = LogEvent.new(0, f, nil, "fake formatter")
    # this checks for tracing
    assert_match(b.format(event), /in/)
    assert_not_match(b.format(event2), /in/)
    e = ArgumentError.new("argerror")
    e.set_backtrace ['backtrace']
    event3 = LogEvent.new(0, f, nil, e)
    assert_match(b.format(event3), /ArgumentError/)
    assert_match(b.format(LogEvent.new(0,f,nil,[1,2,3])), /Array/)
  end
  def test_non_string_data_events
    require 'pp'
    [ SimpleFormatter, BasicFormatter, NullFormatter ].each do | f_cls |
      b = f_cls.new
      f = Logger.new('fake formatter')
      [ nil, 1, 1.234, "A String", :symbol, { :hash_a => 1, :hash_b => 2}, [ :array0, 1 ], TypeError.new("a type error") ].each do | data |
        data.set_backtrace ['backtrace'] if data.respond_to?(:set_backtrace)
        event = LogEvent.new(0, f, caller, data)
        event2 = LogEvent.new(0, f, nil, data)
        pp [ :event, f_cls, data, b.format(event) ]
        pp [ :event2, f_cls, data, b.format(event2) ]
      end
    end
  end

end 

end
