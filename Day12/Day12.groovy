import groovy.transform.ToString
import static Constants.*

class Constants {
  static final DEFAULT_FILE = "input.txt"
  static final ROOT_NODE = 0
  static final FIRST = 0
  static final ZERO = 0
}

/**
 * Vertex that contains a unique identifer and a list of the all the
 * vertices it connects to (by their unique identifer)
 */
@ToString(includeNames=true)
class Vertex {
  /* Unique identifier for this vertex */
  int Id

  /* Identifiers of vertices that this vertex is connected to */
  int[] Edges
}

/**
 * Graph that contains a list of vertices that construct a Graph
 * and helper methods for traversing the graph
 */
class Graph {
  /* Flattened list of vertices in the graph */
  Vertex[] Vertices

  /* Map of ID -> Vertex of all the vertices in the graph (for fast lookup) */
  Map Nodes = [:]

  /**
   * Constructs a graph from a list of
   *
   * @param id to search graph with
   * @return Map[int:Vertex]
   */
  public Graph(Vertex[] vertices) {
    this.Vertices = vertices
    this.Vertices.each { this.Nodes[it.Id] = it }
  }

  /**
   * Creates a Map of IDs to Vertices that are all connected in the graph
   * (map has faster lookup times than a normal list)
   *
   * @param id to search graph with
   * @return Map[int:Vertex]
   */
   private Map Connections(int id) {
    Map visited = [:]
    def queue = [id]
    while (queue) {
      //get the next item in the queue (from the front)
      int next = queue.removeAt(FIRST)

      //queue the nodes that haven't been visited yet
      this.Nodes[next].Edges.findAll { !visited.containsKey(it) }.each { queue << it }

      //mark the current node as visited and increment the index
      visited[next] = this.Nodes[next]
    }
    return visited
  }

  /**
   * Creates a list of IDs that are all connected in the graph
   *
   * @param id to search graph with
   * @return a list of IDs that are all connected
   */
  public int[] ConnectedTo(int id) {
    return this.Connections(id).collect{ key, value -> key }
  }

  /**
   * Finds how many isolated collections of vertices exist in the graph
   *
   * @param id to search graph with
   * @return number of groups not connected in graph
   */
  public int Groups() {
    //copy all the vertices to a new list to mark unvisited nodes
    Vertex[] unvisited = this.Vertices.collect()
    int groups = ZERO
    while (unvisited) {
      //get the first unvisited vertex and find all vertices it's connected to
      Vertex first = unvisited.first()
      Map visited = this.Connections(first.Id)

      //filter out the vertices that were just visited
      unvisited = unvisited.findAll { !visited.containsKey(it.Id) }

      //increment the number of unique groups found
      groups++
    }
    return groups
  }
}

/**
 * Static Class for parsing the input into a list of Vertex
 */
class Parser {
  /* Constants for string parsing */
  static final LINK = "<->"
  static final COMMA = ","
  static final NEWLINE = "\n"
  static final EMPTY = ""
  static final SPACE = " "
  static final RETURN = "\r"

  /* Constants for parsed indices */
  static final VERTEX = 0
  static final EDGES = 1

  /**
   * Converts text input that represents a graph into a graph object
   *
   * @param text input text that represents a graph
   * @return a graph
   */
  public static Graph GetGraph(String text) {
    Vertex[] vertices = text.tokenize(NEWLINE).collect { GetVertex(it) }
    return new Graph(vertices)
  }

  /**
   * Converts a single line from the input to a Vertex object
   * Example of line format:  0 <-> 1, 2, 3
   *
   * @param line string formatted to represent a vertex
   * @return a Vertex
   */
  private static Vertex GetVertex(String line) {
    //parse input "# <-> #, #, #" cleaning and splitting by the link first
    def parts = Clean(line).tokenize(LINK)

    //vertex part of the input should a number
    def id = parts.getAt(VERTEX).toInteger()

    //edge part of the input should be a comma-delimited list of numbers
    def edges = GetEdges(parts.getAt(EDGES))

    //return the new vertex
    return new Vertex(Id: id, Edges: edges)
  }

  /**
   * Converts a comma-delimited string of numbers to a list of integers
   *
   * @param line comma-delimited line of integers
   * @return list of integers
   */
  private static int[] GetEdges(String line) {
    return line.tokenize(COMMA).collect { it.toInteger() }
  }

  /**
   * Removes unnecessary string characters from the line
   *
   * @param line
   * @return number of groups not connected in graph
   */
  private static String Clean(String line) {
    return line.replace(SPACE, EMPTY).replace(RETURN, EMPTY)
  }
}

static void main(String[] args) {
  String filename = args.length > ZERO ? args.getAt(FIRST) : DEFAULT_FILE
  File file = new File(filename)
  //construct graph from the file text
  Graph graph = Parser.GetGraph(file.text)
  //get identifiers of vertices connected to the root node
  int[] connected = graph.ConnectedTo(ROOT_NODE)

  println "${graph.Nodes[ROOT_NODE]} connects to ${connected.size()} nodes" //Part 1
  println "Isolated Groups: ${graph.Groups()}" //Part 2
}
