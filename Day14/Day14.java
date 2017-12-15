import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Day14 {

	public static void main(String[] args) {
		String input = "<input here>";		
		int bits = 0;
		List<List<Integer>> matrix = new ArrayList<List<Integer>>();
		for (int i = 0; i < 128; ++i) {
			String format = String.format("%s-%d", input, i);
			String hash = Hashing.ToHash(format);
			
			List<Integer> binary = HexToBinaryList(hash);
			matrix.add(binary);
			bits += Collections.frequency(binary, 1);
		}
		System.out.println(String.format("Number of 1s: %d", bits));
		int regions = GetRegions(matrix);
		System.out.println(String.format("Number of Regions: %d", regions));
	}
	
	public static Integer GetRegions(List<List<Integer>> matrix) {
		Map<Integer, Map<Integer, Boolean>> visited = new HashMap<Integer, Map<Integer, Boolean>>();
		for (int i = 0; i < matrix.size(); ++i) {
			visited.put(i, new HashMap<Integer, Boolean>());
		}
		
		List<Integer> flattened = new ArrayList<Integer>();
		for (List<Integer> list : matrix) {
			flattened.addAll(list);
		}
		int regions = 0;
		for (int i = 0; i < matrix.size(); ++i) {
			for (int j = 0; j < matrix.get(i).size(); ++j) {
				if (!visited.get(i).containsKey(j) && matrix.get(i).get(j) == 1) {
					//traverse index collecting all indices and initializing them in the hashmap
					Traverse(i, j, visited, matrix);
					regions++;
				}
			}
		}
		return regions;
	}
	
	public class Index { 
	  public final int x; 
	  public final int y; 
	  public Index(int x, int y) { 
	    this.x = x; 
	    this.y = y; 
	  } 
	  
	  public Boolean IsValidIndexOf(List<List<Integer>> matrix) {
		  int height = matrix.size();
		  if (this.x >= height || this.x < 0) {
			  return false;
		  }
		  int width = matrix.get(this.x).size();
		  if (this.y >= width || this.y < 0) {
			  return false;
		  }
		  return true;
	  }
	  
	  @Override
	  public String toString() {
		  return String.format("X: %d, Y: %d", this.x, this.y);
	  }
	} 
	
	public static void Traverse(int i, int j, Map<Integer, Map<Integer, Boolean>> visited, List<List<Integer>> matrix) {
		Day14 _this = new Day14();
		LinkedList<Index> queue = new LinkedList<Index>();
		queue.add(_this.new Index(i, j));
		while (!queue.isEmpty()) {
			Index index = queue.pop();
			if (visited.get(index.x).containsKey(index.y)) {
				continue;
			}
			visited.get(index.x).put(index.y, true);
			queue.addAll(GetPaths(index, matrix, visited));
		}		
	}
	
	public static List<Index> GetPaths(Index index, List<List<Integer>> matrix, Map<Integer, Map<Integer, Boolean>> visited) {
		Day14 _this = new Day14();
		
		Index[] indices = {
			_this.new Index(index.x - 1, index.y),
			_this.new Index(index.x + 1, index.y),
			_this.new Index(index.x, index.y - 1),
			_this.new Index(index.x, index.y + 1),
		};
		List<Index> validIndices = new ArrayList<Index>(); 
		for (Index i : indices) {
			if (i.IsValidIndexOf(matrix) && !visited.get(i.x).containsKey(i.y) && matrix.get(i.x).get(i.y) == 1) {				
				validIndices.add(i);
			}
		}
		return validIndices;
	}
	
	public static List<Integer> HexToBinaryList(String hash) {
	    List<Integer> values = new ArrayList<Integer>();
		for (int i = 0; i < hash.length(); i += 2) {
			String hex = hash.substring(i, i + 2);
			int value = Integer.parseInt(hex, 16);
			String binaryString = Integer.toBinaryString(value);
			while (binaryString.length() < 8) {
				binaryString = "0" + binaryString;
			}
		    for (String s : binaryString.split("")) {
		    	values.add(Integer.valueOf(s));
		    }
		}
	    return values;
	}
	
	public static class Hashing {
		
		public static String ToHash(String input) {
			Day14 _this = new Day14();
			List<Integer> lengths = new ArrayList<Integer>();
			for (char c : input.toCharArray()) {
				lengths.add((int) c);
			}
			int[] ending = {17,31,73,47,23};
			for (int c : ending) {
				lengths.add(c);
			}
			Solver solver = _this.new Solver();
			List<Integer> list = IntStream.range(0, 256).boxed().collect(Collectors.toList());
			list = solver.Rotations(list, lengths, 64);
			String hash = Hashing.Generate(list, 16);
			return hash;
		}
		
		public static String Generate(List<Integer> list, int base) {
			List<Integer> compressed = Hashing.Compress(list, base);
			return ToHexadecimal(compressed).toLowerCase();
		}
		
		public static String ToHexadecimal(List<Integer> list) {
			String hexadecimal = "";
			for (int i : list) {
				String hex = Integer.toHexString(i);
				if (hex.length() == 1) {
					hex = "0" + hex;
				}
				hexadecimal += hex;
			}
			return hexadecimal;
		}
		
		public static List<Integer> Compress(List<Integer> list, int size) {
			List<Integer> compressedList = new ArrayList<Integer>();
			int chunks = list.size() / size;
			for (int chunk = 0; chunk < chunks; ++chunk) {
				int value = 0;
				for (int i = chunk * size; i < (chunk + 1) * size; ++i) {
					value ^= list.get(i);
				}
				compressedList.add(value);
			}			
			return compressedList;
		}
	}
	
	public class Solver {
		public int start;
		public int skip;
		
		public Solver() {}
		
		public List<Integer> Rotate(List<Integer> list, List<Integer> lengths) {			
			for (int length : lengths) {
				list = CyclicEnum.ReverseSlice(list, this.start, length);
				this.start = (start + length + skip) % list.size();
				this.skip++;
			}
			return list;
		}
		
		public List<Integer> Rotations(List<Integer> list, List<Integer> lengths, int amount) {			
			this.start = 0;
			this.skip = 0;
			
			for (int i = 0; i < amount; ++i) {
				list = this.Rotate(list, lengths);
			}
			
			return list;
		}
	}
	
	public static class CyclicEnum {
		
		public static List<Integer> ReverseSlice(List<Integer> list, int start, int count) {
			int length = list.size();
			int last = start + count;
			if (last >= length) {
				List<Integer> front = list.subList(start, length);
				List<Integer> back = list.subList(0, start);
				List<Integer> cycled = new ArrayList<Integer>();

				cycled.addAll(front);
				cycled.addAll(back);
				
				Collections.reverse(cycled.subList(0, count));
				return Repair(cycled, start);
			} 
			else {
				Collections.reverse(list.subList(start, start + count));
			}			
			return list;
		}
		
		public static List<Integer> Repair(List<Integer> list, int start) {
			int length = list.size();
			int split = length - start;
			List<Integer> front = list.subList(split, length);
			List<Integer> back = list.subList(0, split);
			List<Integer> repairedList = new ArrayList<Integer>();
			
			repairedList.addAll(front);
			repairedList.addAll(back);
			
			return repairedList;
		}
	}
}
