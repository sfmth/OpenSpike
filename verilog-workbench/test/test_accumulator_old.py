import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random
import math
from cocotb.handle import RealObject
from bitstring import BitArray
# print(BitArray(bin="0b111").int)

def text_to_decimal(text):
    ascii_values = [ord(character) for character in text]
    a =int(''.join(str(bin(i)[2:].zfill(8)) for i in ascii_values), 2)
    return a

def sgined_bin_to_int(a):
    a_b = "0b" + str(a)
    return BitArray(bin=a_b).int

def bin_to_int(a):
    return int(bin(a),2)

def angle_to_int(a):
    return int(62/180*a)
    
def int_to_angle(a):
    return 180/62*a

def value_to_int(a):
    return int(62/2*a)

def int_to_value(a):
    return 2/62*a

async def reset(dut):
    dut.reset.value = 1

    await ClockCycles(dut.clk, 5)
    dut.reset.value = 0
async def convert_values(dut):
    while True:
        # print(int_to_value(bin_to_int(dut.reg_x.value)))
        # print(sgined_bin_to_int(dut.reg_z.value))
        dut.read_x.value = text_to_decimal(str(round(int_to_value(sgined_bin_to_int(dut.reg_x.value)), 2)))
        dut.read_y.value = text_to_decimal(str(round(int_to_value(sgined_bin_to_int(dut.reg_y.value)), 2)))
        dut.read_z.value = text_to_decimal(str(round(int_to_angle(sgined_bin_to_int(dut.reg_z.value)), 2)))
        await Timer(1, units='us')

def shift_add_mult(beta, potential):
    potential_2 = int(potential/2) # >> 1
    potential_4 = int(potential/4) # >> 2
    potential_8 = int(potential/8) # >> 3
    
    if (beta == 0):
        return 0
    
    elif (beta == 1):
        return potential_8
    
    elif (beta == 2):
        return potential_4
    
    elif (beta == 3):
        return potential_4 + potential_8
    
    elif (beta == 4):
        return potential_2
    
    elif (beta == 5):
        return potential_2 + potential_8
    
    elif (beta == 6):
        return potential_2 + potential_4
    
    elif (beta == 7):
        return potential_2 + potential_4 + potential_8
    
    elif (beta == 8):
        return potential

def and_w_spk(w,spk):
    synapse = 0
    if (w == 1):
        if (spk == 1):
            synapse += 1
        if (spk == 3):
            synapse += 1
    if (w == 2):
        if (spk == 2):
            synapse += 1
        if (spk == 3):
            synapse += 1
    if (w == 3):
        if (spk == 1):
            synapse += 1
        if (spk == 2):
            synapse += 1
        if (spk == 3):
            synapse += 2
    return synapse

async def w_spk_in(dut, spk_in, w_read):
    
    # while True:
    for i in range(512):
        # dut.cntr.value = i
        dut.w_in.value = w_read[i]
        dut.spk_in.value = spk_in[i]
        await Timer(10, units='us')
    # await ClockCycles(dut.clk, 10)



@cocotb.test()
async def test_shift_add_mult(dut):
    # dut.io_in.value = 0 # initialize
    await Timer(10, units='us')
    # clock = Clock(dut.clk, 10, units="us")
    # cocotb.fork(clock.start())
    
    # await reset(dut) # reset

    
    # cocotb.fork(convert_values(dut))
    synapse_sum = []
    for j in range(100):
        
        spk_in = []
        w_read = []
        for i in range(512):
            spk_in.append(random.randint(0, 3))
            w_read.append(random.randint(0, 3))

        synapse = []
        for i in range(512):
            synapse.append(and_w_spk(w_read[i], spk_in[i]))
        
        synapse_sum.append(sum(synapse))

        # start the test
        cocotb.fork(w_spk_in(dut, spk_in, w_read))
        # w_spk_in(dut, spk_in, w_read).start()
        for i in range(512):
            if ( i == 510):
                await ClockCycles(dut.clk, 1)
                dut.oen.value = 1
                dut.reset.value = 1
                await ClockCycles(dut.clk, 1)
                dut.oen.value = 0
                dut.reset.value = 0
                # await RisingEdge(dut.clk)
                # await ClockCycles(dut.clk, 1)
                break
            await ClockCycles(dut.clk, 1)
            if (j != 0 and i == 0):
                if (synapse_sum[j-1] <= 255):
                    assert(bin_to_int(dut.accumulated_potential.value) == synapse_sum[j-1])
                else:
                    assert(bin_to_int(dut.accumulated_potential.value) == 255)

        # print("***synapse sum***")
        # print(synapse_sum[j])

        

    # print(op)
    # print(funct3)
    # print(funct7_5)
    # print(len(op))
    # test a range of values
    # await RisingEdge(dut.clk2)
    # for i in range(0, 2**32, 2**28):
    #     for j in range(2**7):
    #         dut.we.value = 1
    #         dut.write_data.value = i
    #         dut.write_addr.value = j
    #         await RisingEdge(dut.clk2)
    #         dut.we.value = 0
    #         dut.read_addr.value = j
    #         await RisingEdge(dut.clk2)
    #         assert(bin_to_int(dut.read_data.value) == i)
    # i = 2**32-1
    # for j in range(2**7):
    #         dut.we.value = 1
    #         dut.write_data.value = i
    #         dut.write_addr.value = j
    #         await ClockCycles(dut.clk, 2)
    #         dut.we.value = 0
    #         dut.read_addr.value = j
    #         await ClockCycles(dut.clk, 2)
    #         assert(bin_to_int(dut.read_data.value) == i)
            # await ClockCycles(dut.clk, 20)
        #     dut.beta.value = i
        #     dut.potential.value = j
        #     await Timer(10, units='us')
        #     assert(shift_add_mult(i, j) == bin_to_int(dut.mult_ans.value))
            
        


        # pass
        # dut.op.value = op[i]
        # dut.funct3.value = funct3[i]
        # dut.funct7_5.value = funct7_5[i]
        # dut.inst.value = text_to_decimal(instruction[i])
                # dut.real_ans_x.value = f"{angle}"
        # dut.real_ans_y.value = math.sin(angle)


        # print(op[i])
        # set pwm to this level
        # await FallingEdge(dut.clk)
        # # dut.address_1.value = i
        # await Timer(1, units='us')
        # # dut.address_2.value = i
        # await Timer(1, units='us')
        # dut.address_3.value = i
        # await Timer(1, units='us')
        # data = random.randint(0, 4294967295)
        # dut.write_data.value = data
        # await Timer(1000, units='ps')
        # wait pwm level clock steps
        

        # angle = random.randint(-90,90)
        # dut.z0.value = angle_to_int(angle)
        # dut.inp_angle.value = text_to_decimal(str(angle))
        # # set_signal_val_real(dut.real_ans_x.value, math.cos(angle))
        # # dut.real_ans_x._set_value(math.cos(angle), call_sim)
        # dut.real_ans_x.value = text_to_decimal(str(round(math.cos(math.radians(angle)), 2)))
        # dut.real_ans_y.value = text_to_decimal(str(round(math.sin(math.radians(angle)), 2)))

        # await reset(dut) # reset
        # if (i > 150):
        #     await FallingEdge(dut.clk)
        #     if (io)
        # # assert still high
        # if (i != 0):
        #     assert(dut.read_data_1.value == data)
        #     assert(dut.read_data_2.value == data)
    
