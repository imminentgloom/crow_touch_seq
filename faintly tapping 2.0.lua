--- [...]faintly you came tapping, tapping at my chamber door 2.0 //////// Imminent gloom
-- A touch-based sequencer for crow and landscape.fm's allflesh (and noon), and w//

-- Plug touchplates into the inputs, don't touch them and power you case on so
-- crow can get an idea of where zero is and calibrate them correctly.

-- Time is sett using a W/del linked over the ii bus, the sequences follow
-- the delaytime. Rate currently multiplies the sequence time, but I would like
-- to not be the case and for it to only affect the delaytime.

-- Input 1: Touchpad, valtages here creates the first pattern
-- Input 2: Touchpad, voltages here creates the second pattern

-- Output 1: Touchpad, +5v, add gates to pattern
-- Output 2: Touchpad, -5v, remove gates
-- Output 3: This is where the first sequence of gates emerges
-- Output 4: This is where the second sequcence of gates emgerges

v_cal_1 = 0.0
v_cal_2 = 0.0
threshold_1 = 0.1
threshold_2 = 0.1
s1 = {}
s2 = {}
length_1 = 24 * 4  -- 4 beats @ 24ppqn
length_2 = 24 * 4
step_1 = 0
step_2 = 0
del_time = 0.5
del_rate = 0.5

function init()
  v_cal_1 = input[1].volts  -- get approximate zero for the inputs
  v_cal_2 = input[2].volts
  for n = 1,length_1 do s1[n] = 0.0 end
  for n = 1,length_2 do s2[n] = 0.0 end
  input[1].mode('stream', 0.001)
  input[2].mode('stream', 0.001)
  output[1].volts = -5
  output[2].volts = 5
  clock.run(timecheck)
  clock.run(clockwork)
end

ii.wdel.event = function(e, value)  -- lets w.del answer when we ask about time
  if e.name == 'time' and e.device == 1 then del_time = value end
  if e.name == 'rate' and e.device == 1 then del_rate = value end
end

function timecheck()
  while true do
    ii.wdel[1].get 'time'
    ii.wdel[1].get 'rate'
    clock.tempo = 60 / del_time / 4
    clock.sleep(0.01)
  end
end

function clockwork()
  while true do
    clock.sync(1 / 4 / 24)
    step_1 = step_1 + 1
    step_2 = step_2 + 1
    if step_1 > length_1 then step_1 = 0 end
    if step_2 > length_2 then step_2 = 0 end
  end
end

input[1].stream = function()
  if input[1].volts - v_cal_1 > threshold_1 then s1[step_1] = 10.0 end
  if input[1].volts - v_cal_1 < 0 - threshold_1 then s1[step_1] = 0.0 end
  output[3].volts = s1[step_1]
end

input[2].stream = function()
  if input[2].volts - v_cal_2 > threshold_2 then s2[step_2] = 10.0 end
  if input[2].volts - v_cal_2 < 0 - threshold_2 then s2[step_2] = 0.0 end
  output[4].volts = s2[step_2]
end