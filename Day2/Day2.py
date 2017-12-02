'''Basic Characters for splitting/removing in strings'''
NEWLINE = '\n'
TAB = '\t'
CARRIAGE_RETURN = '\r'
SPACE = ' '
EMPTY = ''

'''Being Part #1'''

'''
Takes in a string representation of a matrix like such:
5 9 2 8
9 4 7 3
3 8 6 5
and computes the checksum (different of the max and 
min of each row, summed together).
'''
def getResultPart1(input):
  #Spaces > Tabs, so lets use spaces because we are opinionated
  input = input.replace(TAB, SPACE)
  
  #People might be on windows, too. Convert CR-LF to LF
  input = input.replace(CARRIAGE_RETURN, EMPTY)
  
  #Get the rows from the string representation of the matrix
  rows = input.split(NEWLINE)
  diffsums = 0
  for row in rows:
    values = [int(value) for value in row.split(SPACE)]
    diffsums += max(values) - min(values)
  return diffsums

'''Begin Part #2'''

'''Check if i divides j or j divides i'''
def isDivisible(i, j):
  return (i % j == 0) or (j % i == 0)

'''
Get the whole number division between two numbers; if neither divide, return 0
'''
def divides(i, j): 
  if i % j == 0: 
    return i / j
  elif j % i == 0:
    return j / i
  else:
    return 0
  
'''
Takes in a string representation of a matrix like such:
5 9 2 8
9 4 7 3
3 8 6 5
and computes the checksum (the value of two numbers from each row that divide eachother, summed for each row).
'''
def getResultPart2(input):
  #Spaces > Tabs, so lets use spaces because we are opinionated
  input = input.replace(TAB, SPACE)
  
  #People might be on windows, too. Convert CR-LF to LF
  input = input.replace(CARRIAGE_RETURN, EMPTY)
  
  #Get the rows from the string representation of the matrix
  rows = input.split(NEWLINE)
  
  diffsums = 0
  for row in rows:
    values = [int(value) for value in row.split(SPACE)]
    
    #get all forward combinations in the values from the row
    combinations = [(first, second) for i, first in enumerate(values) for j, second in enumerate(values[i + 1:])]
    
    #find the first combination where either number divides the other with no remainder
    divisibleCombination = next(combination for combination in combinations if isDivisible(*combination))
    
    #get the value of the division with no remainder and add it to the sum
    diffsums += divides(*divisibleCombination)
  return diffsums
