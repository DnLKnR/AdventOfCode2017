;;This program solves Day 11 of the Advent Of Code 2017 challenges
;;
;;A coordinate-plane is used to model, but limited to every other
;;space an order to create a hexagonal model, for example:
;;
;;NW      N      NE
;;  [ o x o x o ]
;;  [ x o x o x ]    (o = valid location, x = invalid)
;;W [ o x o x o ] E 
;;  [ x o x o x ] 
;;  [ o x o x o ]
;;SW      S      SE
;;
;;Center of the coordinate-plane shown above is [x:0 y:0]
;;
;;Valid directions are: 
;;  North, South, Northwest, Southwest, Northeast, Southeast.
;;
;;This means that travelling directly North/South allows a jump
;;of two spaces across the Y, while any other direction results in a 
;;diagonal movement (one space across the X, one space across the Y).

;;library for string parsing
(require '[clojure.string :as string])

;;filename with the input
(def ^:const FILENAME "input.txt")

;;for string parsing
(def ^:const EMPTY "")
(def ^:const SPACE " ")
(def ^:const NEWLINE "\n")

;;constant numbers that are used in the program
(def ^:const ZERO 0)
(def ^:const ONE 1)
(def ^:const TWO 2)

;;delimiter regex for splitting the data
(def ^:const DELIMITER (re-pattern ","))

;;directions from the input
(def ^:const NORTH "n")
(def ^:const SOUTH "s")
(def ^:const NORTHWEST "nw")
(def ^:const NORTHEAST "ne")
(def ^:const SOUTHWEST "sw")
(def ^:const SOUTHEAST "se")

;;center location
(def ^:const CENTER [ZERO ZERO])

;;gets the absolute value
(defn absolute [value] (max value (- value)))

;;functions that take one step in the direction of their name
(defn north [x y] [x (+ y TWO)])
(defn south [x y] [x (- y TWO)])
(defn northeast [x y] [(+ x ONE) (+ y ONE)])
(defn northwest [x y] [(- x ONE) (+ y ONE)])
(defn southeast [x y] [(+ x ONE) (- y ONE)])
(defn southwest [x y] [(- x ONE) (- y ONE)])

;;change the location ([x y]) one step in the specified direction
(defn go [direction [x y]]
  (condp = direction
    NORTH     (north x y)
    NORTHEAST (northeast x y)
    NORTHWEST (northwest x y)
    SOUTH     (south x y)  
    SOUTHEAST (southeast x y)
    SOUTHWEST (southwest x y)))

;;counts steps from center ([0, 0]) to location entered
(defn steps [[x y]]
  ;;get the absolute coordinates
  (def absolute-x (absolute x))
  (def absolute-y (absolute y))
  (if
    ;;if abs(x) > abs(y), then you will have to travel diagonally
    ;;to get back to the center the whole time (zig-zagging and whatnot)
    (>= absolute-x absolute-y) absolute-x
    ;;otherwise, you travel diagonally until vertically aligned,
    ;;then you can jump by 2 the rest of the way
    (+ (/ (- absolute-y absolute-x) TWO) absolute-x)))

;;read the text of the file
(def input (slurp FILENAME))

;;get rid of newline and spaces from our input
(def input (string/replace input NEWLINE EMPTY))
(def input (string/replace input SPACE EMPTY))

;;split data by the delimiter to get the directions
(def directions (string/split input DELIMITER))

;;initialize our coordinates, distance, and max distance
(def location CENTER)
(def distance (steps location))
(def max-distance distance)

;;iterate through the sequence of directions,
;;traverse and update
(doseq [direction directions] 
  (def location (go direction location))
  (def distance (steps location))
  (def max-distance (if (> distance max-distance) distance max-distance)))

(println "End Distance:" distance)
(println "Max Distance:" max-distance)
