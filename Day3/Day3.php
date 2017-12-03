<?php
/*
Finds the Manhattan Distance to the desired input number, where
the values are spiralled out from the center. For example:
17  16  15  14  13
18   5   4   3  12
19   6   1   2  11
20   7   8   9  10
21  22  23---> ...
*/
function getResultPart1($input) {
  if ($input < 0) {
    return 0;
  }
  
  //2D matrix (not scalable to 3D, would need other changes as well)
  $total_dimensions = 2;
  $total_edges = 2 ** $total_dimensions;
  
  //get the dimension of the matrix 
  //(this way our input number will be on the outer edge)
  $dimension = ceil(sqrt($input));
  
  //the dimensions of the square will always be odd (so make sure dimension is odd)
  if ($dimension % 2 == 0) {
    ++$dimension;
  }
  
  //steps to the outer ring (where the input number will be)
  $steps_to_outer_ring = floor($dimension / $total_dimensions);
  
  //steps from outer ring corner to midpoint (same as steps to outer ring)
  $steps_outer_corner_to_midpoint = $steps_to_outer_ring;
  
  //highest value in the matrix (will be located at one of the corners)
  $highest_value = $dimension ** $total_dimensions;
  
  //initialize our steps to the value to get to the outer ring
  $total_steps = $steps_to_outer_ring;
  
  //we need to figure out which side our number is on, 
  //then compute the steps travelled along the outer edge
  for ($edge = 1; $edge <= $total_edges; ++$edge) {
    //compute the lowest number on each side to find where our input number is located
    //NOTE: give each side its own corner, makes computing easier (thus the minus 1)
    $side_lowest_value = $highest_value - (($dimension - 1) * $edge);
    
    //see if we have find the side our number is on
    if ($side_lowest_value <= $input) {
      //we found the side, compute the midpoint 
      $side_midpoint_value = $side_lowest_value + $steps_outer_corner_to_midpoint;
      
      //add the distance travelled along the outer edge to the total steps
      $total_steps += abs($input - $side_midpoint_value);
      break;
    }
  }
  print("Input: $input, Required Steps: $total_steps\n");
  return $total_steps;
}

/*
Begin Part 2
*/

/* Static class used to maintain constant values for directions and rotations
*/
abstract class Direction {
  //Linear Direction
  const RIGHT = 0;
  const DOWN = 1;
  const LEFT = 2;
  const UP = 3;
  
  const FIRST_DIRECTION = self::RIGHT;
  const LAST_DIRECTION = self::UP;
  
  //UP, DOWN, LEFT, RIGHT
  const TOTAL_DIRECTIONS = 4;
  
  //Increments for rotations on direction
  const DIRECTION_INCREMENTS = 1;
  
  //Rotation Direction
  const CLOCKWISE = 0;
  const COUNTER_CLOCKWISE = 1;
  
  public static function next($direction, $rotation_type) {
    switch ($rotation_type) {
      case self::CLOCKWISE:
        return ($direction + self::DIRECTION_INCREMENTS) % self::TOTAL_DIRECTIONS;
      case self::COUNTER_CLOCKWISE:
      default:
        return $direction == self::FIRST_DIRECTION ? self::LAST_DIRECTION : $direction - self::DIRECTION_INCREMENTS;
    }
  }
}

/* Creates a spiralled matrix, where each index is computed based on its
neighbors.

Example of the matrix 5x5:
147  142  133  122   59
304    5    4    2   57
330   10    1    1   54
351   11   23   25   26
362  747  806--->   ...

As each number is placed, the sum of its neighbors is used to compute
its own value. Thus, the pattern of 1, 1, 2, 4, 5, 10, etc., while
spiralling outward the direction specified
*/
class SpiralMatrix {
  const VALUE_NOT_SET = 0;
  const TOTAL_DIMENSIONS = 2;
  
  private $dimension;
  private $total_dimensions;
  private $initial_value;
  private $initial_direction;
  private $rotation_type;
  private $matrix;
  private $is_populated;
  
  public function __construct($dimension, $initial_value, $initial_direction, $rotation_type) {
    $this->dimension = $dimension;
    $this->initial_value = $initial_value;
    $this->initial_direction = $initial_direction;
    $this->rotation_type = $rotation_type;
    
    $initial_index = 0;
    $this->matrix = array_fill($initial_index, $dimension, array_fill($initial_index, $dimension, self::VALUE_NOT_SET));
    
    $this->is_populated = false;
  }
  
  /* Returns true if index is out-of-bounds; otherwise, false. */
  private function invalid($row, $column) {
    $height = count($this->matrix);
    if ($row >= $height || $row < 0) {
      return true;
    }
    $length = count($this->matrix[$row]);
    if ($column >= $length || $column < 0) {
      return true;
    }
    return false;
  }
  
  /* Returns next row index based on direction */
  private function getNextRow($direction, $row) {
    switch ($direction) {
      case Direction::UP:
        return $row - 1;
      case Direction::DOWN:
        return $row + 1;
      case Direction::LEFT:
      case Direction::RIGHT:
      default:
        return $row;
    }
  }
  
  /* Returns next column index based on direction */
  private function getNextColumn($direction, $column) {
    switch ($direction) {
      case Direction::LEFT:
        return $column - 1;
      case Direction::RIGHT:
        return $column + 1;
      case Direction::UP:
      case Direction::DOWN:
      default:
        return $column;
    }
  }
  
  /* Returns the next direction that should be traversed in the matrix */
  private function getNextDirection($direction, $row, $column) {
    $next_direction = Direction::next($direction, $this->rotation_type);
    $next_row = $this->getNextRow($next_direction, $row);
    $next_column = $this->getNextColumn($next_direction, $column);
    
    //is value at the next rotation direction need to be set; if so, change direction
    if ($this->get($next_row, $next_column) === self::VALUE_NOT_SET) {
      return $next_direction;
    }
    //otherwise, continue the same direction
    return $direction;
  }
  
  /* Get Value in Matrix at $row, $column */
  private function get($row, $column) {
    return $this->invalid($row, $column) ? self::VALUE_NOT_SET : $this->matrix[$row][$column];
  }
  
  /* Set Value in Matrix at $row, $column */
  private function set($row, $column, $value) {
    if (!$this->invalid($row, $column)) {
      $this->matrix[$row][$column] = $value;
    }
  }
  
  /* Returns the value of the current index (by adding itself and its neighbors).
     WARNING: This function adds value at the specified index as well 
     
     This function could be made replaceable to create different patterns of
     sprial matrices */
  private function compute($row, $column) {
    $upper_row = $this->getNextRow(Direction::UP, $row);
    $lower_row = $this->getNextRow(Direction::DOWN, $row);
    $rows = array($upper_row, $row, $lower_row);
    
    $left_column = $this->getNextColumn(Direction::LEFT, $column);
    $right_column = $this->getNextColumn(Direction::RIGHT, $column);
    $columns = array($left_column, $column, $right_column);
    
    //compute the sum of 3 by 3 square
    $sum = 0;
    foreach($rows as $row) {
      foreach($columns as $column) {
        $sum += $this->get($row, $column);
      }
    }
    return $sum;
  }
  
  /* Set that the matrix has been populated */
  private function setPopulated() {
    $this->is_populated = true;
  }
  
  /* Is the matrix populated */
  private function isPopulated() {
    return $this->is_populated;
  }
  
  /* Populate the matrix with the spiral values */
  private function populate() {
    if ($this->isPopulated()) {
      return;
    }
    //compute the midpoint and use it to select the starting indexes
    $midpoint = floor($this->dimension / self::TOTAL_DIMENSIONS);
    
    //initialize indexes to the center of the matrix
    $row = $midpoint;
    $column = $midpoint;
    
    //starting direction for the spiral is right
    $direction = $this->initial_direction;
    
    //initialize the starting value at the center of the matrix
    $value = $this->initial_value;
    $this->set($row, $column, $value);
    
    while(!$this->invalid($row, $column)) {
      $value = $this->compute($row, $column);
      $this->set($row, $column, $value);
      
      //get next direction, row, and column for the next value
      $direction = $this->getNextDirection($direction, $row, $column);
      $row = $this->getNextRow($direction, $row);
      $column = $this->getNextColumn($direction, $column);
    }
    $this->setPopulated();
  }
  
  /* Finds a value larger than the $input in the matrix, which is
     closest to $input without matching it*/
  public function getFirstLargerValueThan($input) {
    //populate the matrix
    $this->populate();
    
    $diff = -1;
    $closestLargerValue = -1;
    foreach($this->matrix as $row) {
      foreach($row as $value) {
        //check if the current value is closer to the input value; if so, use it
        $new_diff = $value - $input;
        if ($diff <= 0 || $new_diff > 0 && $new_diff < $diff) {
          $diff = $new_diff;
          $closestLargerValue = $value;
        }
      }
    }
    return $closestLargerValue;
  }
}

/* Takes in an input and finds the first larger number in a spiral matrix.
   See Class comment for SpiralMatrix */
function getResultPart2($input) {
    //special case for 1, since 1x1 matrix won't have a higher value than 1
    $input_for_dimension = $input === 1 ? $input + 1 : $input;
    
    //get the dimension of the matrix 
    //(this way our input number will be on the outer edge)
    $dimension = ceil(sqrt($input_for_dimension));
    
    //the dimensions of the square will always be odd (so make sure dimension is odd)
    if ($dimension % 2 == 0) {
      ++$dimension;
    }
    //the value we should start the center of the matrix at
    $center_value = 1;
    $spiralMatrix = new SpiralMatrix($dimension, $center_value, Direction::RIGHT, Direction::COUNTER_CLOCKWISE);
    
    $result = $spiralMatrix->getFirstLargerValueThan($input);
    print("First Larger Value than $input: $result\n");
    return $result;
}
?>