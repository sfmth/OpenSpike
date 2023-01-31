import math
import matplotlib
import matplotlib.pyplot as plt

matplotlib.use('wxAgg')

# 0
# ans = 0
# 15
# ans = p/8
# 47
# ans = p/4
# 79
# 111
# 143
# 175
# 207
# 239
# 255
def mult(beta, potential):
    return int((beta/8)*potential)

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
    
error = []
for i in range(9):
    for j in range(256):
        error_i_j = shift_add_mult(i,j) - mult(i,j)
        error.append(error_i_j)
print("Maximum error of the method:")
print(max(error))

U = 122
beta = []
ans = []
for i in range(9):
    beta.append(i)
    ans.append(shift_add_mult(i,U))
    
fig, ax = plt.subplots()
ax.step(beta, ans, where='mid')
ax.grid()
ax.set(xlabel='beta', ylabel='shift-add multiplication',
       title='shift-add multiplication for U=122')
fig.savefig("test.png")
plt.show()
# print(shift_add_mult(187, 153))

# for i in range(20):
#     if ((i*1/16)%(1/8)):
#         print(int((i*1/16)*255))

