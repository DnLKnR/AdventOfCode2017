using System;
using System.Linq;
using System.Collections.Generic;

namespace Day7
{
    public class Program
    {
        static void Main(string[] args)
        {
            var input = System.IO.File.ReadAllText(@"input.txt");
            Parser parser = new Parser(input);
            Node root = parser.Nodes.Values.FirstOrDefault(node => string.IsNullOrEmpty(node.Parent));
            
            int total = root.Sum(parser.Nodes);
            Node problem = root.FindProblemChild(parser.Nodes);

            Console.WriteLine(string.Format("Root: {0}", root));
            Console.WriteLine(string.Format("Problem: {0}", problem));
            int correction = parser.Nodes.GetUnevenAmount(root);
            Console.WriteLine(string.Format("Correction: {0}", problem.CorrectId(correction)));
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }        
    }

    public class Parser
    {
        const string ARROW = "->";
        const string SPACE = " ";
        const string COMMA = ",";
        const string OPEN_PAREN = "(";
        const string CLOSE_PAREN = ")";

        public Dictionary<string, Node> Nodes { get; } = new Dictionary<string, Node>();

        public Parser(string input)
        {
            //get rid of spaces
            input = input.Replace(" ", string.Empty);

            //sort by children first
            foreach (string nodeString in input.Split(Environment.NewLine))
            {
                var (id, name, children) = this.Parse(nodeString);
                Node node = new Node(id, name, children);
                this.Nodes[node.Name] = node;
            }
            this.Nodes.ForEachValue(this.Nodes.ConnectParent);
        }

        public (int id, string name, List<string> children) Parse(string nodeString)
        {
            //Get rid of spaces, then split XXXXX(##)->XXXXX,XXXXX,XXXX by '->'
            string[] parts = nodeString.Replace(SPACE, string.Empty).Split(ARROW);

            //name should be of format "XXXXX(##)", convert => ["XXXXX", "##"]
            string nameIdString = parts.First();
            string[] nameId = nameIdString.Replace(CLOSE_PAREN, string.Empty).Split(OPEN_PAREN);

            //Name should be the XXXXX part of the format
            var name = nameId.First();

            //ID should be the ## part of the format
            var id = int.Parse(nameId.Last());

            //parse the children from the XXXXX,XXXXX,XXXX portion of the string 
            //(if name matches childrenString, then no children exist on string)
            string childrenString = parts.Last();
            var children = nameIdString.Matches(childrenString) ? new List<string>() : childrenString.Split(COMMA).ToList();

            return (id, name, children);
        }
    }
    
    public class Node
    {
        public int Id { get; private set; }

        public string Name { get; private set; }

        public string Parent { get; set; }

        public List<string> Children { get; private set; }

        public int Total { get; set; }

        public Node(int id, string name, List<string> children)
        {
            this.Id = id;
            this.Name = name;
            this.Children = children.ToList();
        }

        public void Update(Dictionary<string, Node> nodes)
        {
            //set the sums for all the nodes
            this.Sum(nodes);
        }

        public int Sum(Dictionary<string, Node> nodes)
        {
            int sum = 0;
            foreach (string child in this.Children)
            {
                sum += nodes[child].Sum(nodes);
            }
            this.Total = sum + this.Id;
            return this.Total;
        }

        /// <summary>
        /// Detects the lowest child that causes an uneven total amount this nodes children.
        /// 
        /// If this function return null, all children are balanced.
        /// </summary>
        /// <param name="nodes"></param>
        /// <returns></returns>
        public Node FindProblemChild(Dictionary<string, Node> nodes)
        {
            //loop through each child and attempt to detect
            foreach (string child in this.Children)
            {
                Node problem = nodes[child].FindProblemChild(nodes);
                if (problem != null)
                {
                    return problem;
                }
            }
            var childTotals = this.Children.Select(child => nodes[child].Total);
            if (!childTotals.AllEqual())
            {
                var uniqueValue = childTotals.Unique();
                var child = this.Children.First(c => nodes[c].Total == uniqueValue);
                return nodes[child];
            }
            return null;
        }

        public Node CorrectId(int correction)
        {
            return new Node(this.Id - correction, this.Name, this.Children);
        }

        /// <summary>
        /// Tuple-Deconstructing Node-Constructor
        /// </summary>
        /// <param name="tuple"></param>
        public Node((int id, string name, List<string> children) tuple) : this(tuple.id, tuple.name, tuple.children) { }


        public override string ToString()
        {
            return string.Format("{1} ({0})", this.Id, this.Name, this.Total);
        }
    }

    public static class Extensions
    {
        /// <summary>
        /// Connects the <see cref="Node.Children"/> of the <see cref="Node"/>, 
        /// through use of the <see cref="Dictionary{string, Node}"/>.
        /// </summary>
        /// <param name="nodes">Dictionary of Node names to Node objects</param>
        /// <param name="parent">Node being connected</param>
        public static void ConnectParent(this Dictionary<string, Node> nodes, Node parent) => parent.Children.ForEach(child => nodes[child].Parent = parent.Name);

        /// <summary>
        /// Check if all items in a list are the same.
        /// </summary>
        /// <param name="nodes">Dictionary of Node names to Node objects</param>
        /// <param name="parent">Node being connected</param>
        public static bool AllEqual<T>(this IEnumerable<T> items) => !items.Distinct().Skip(1).Any();

        /// <summary>
        /// Convenience function allowing the ForEach function to be called 
        /// on an <typeparamref name="IEnumerable{T}"/>.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="values"></param>
        /// <param name="action"></param>
        public static void ForEachValue<TKey, TValue>(this Dictionary<TKey, TValue> dictionary, Action<TValue> action) => dictionary.Values.ToList().ForEach(action);

        /// <summary>
        /// Compares two strings to see if they are equivalent in value.
        /// Case-Sensitive; returns false on null.
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public static bool Matches(this string a, string b) => string.Equals(a, b);

        /// <summary>
        /// Finds the unique value in the list and returns it.
        /// 
        /// Warning: This will return default value for type if used on an empty list.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="values"></param>
        /// <returns></returns>
        public static T Unique<T>(this IEnumerable<T> values) where T : struct => values.Where(value => values.Count(v => v.Equals(value)) == 1).First();

        /// <summary>
        /// Returns the difference required to balance out the <see cref="Node.Total"/> for children of the root node.
        /// </summary>
        /// <param name="nodes"></param>
        /// <param name="root"></param>
        /// <returns></returns>
        public static int GetUnevenAmount(this Dictionary<string, Node> nodes, Node root)
        {
            var totals = root.Children.Select(child => nodes[child].Total);
            var distinct = totals.Distinct();
            distinct.OrderBy(value => totals.Count(total => value == total));
            return distinct.Last() - distinct.First();
        }
    }
}


