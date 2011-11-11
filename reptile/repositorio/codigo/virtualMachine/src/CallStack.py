class CallStack (object):
  def __init__ (self):
    self.stack = []

  def push (self, item):
    self.stack.append ( item )

  def pop (self):
    return self.stack.pop()

  def peek (self):
    return self.stack[len(self.stack) - 1]

  def isEmpty (self):
    return (len(self.stack) == 0)

  def size (self):
    return (len(self.stack))

