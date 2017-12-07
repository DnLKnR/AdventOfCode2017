let NEWLINE: Character = "\n"
let TAB: Character = "\t"
let SPACE: Character = " "
let COMMA_SEPARATOR: String = ", "

class DistributionState {
    var hasDistributed: Bool
    var hasConfigured: Bool
    
    init() {
        self.hasConfigured = false;
        self.hasDistributed = true;        
    }
    
    func CanConfigure() -> Bool {
        return !self.hasConfigured && self.hasDistributed;
    }
    
    func EndConfiguration() {
        self.hasConfigured = true;
        self.hasDistributed = false;
    }
    
    func CanDistribute() -> Bool {
        return !self.hasDistributed && self.hasConfigured;
    }    
    
    func EndDistribution() {
        self.hasConfigured = false;
        self.hasDistributed = true;
    }
}

class Distributor {
    var products = [Int]()
    var configurations = [String: Int]()
    var state: DistributionState = DistributionState()
    var total: Int = 0
    var hasCycled: Bool = false
    
    init(input: String, separator: Character) {
        let values = input.split(separator: separator)
        for value in values {
            let number = Int(value)!
            self.products.append(number)
        }
    }
    
    func Distribute(atIndex: Int) {
        if !self.state.CanDistribute() {
            return;
        }
        let value: Int = self.products[atIndex]
        var index: Int = atIndex
        self.products[atIndex] = 0
        for _ in stride(from: 0, to: value, by: 1) {
            index = (index + 1) % self.products.count
            self.products[index] += 1
        }
        self.state.EndDistribution()
    }
    
    func CycleDetected() -> Bool {
        if self.state.CanConfigure() && !self.hasCycled {  
            var configuration: String = self.Configuration()
            self.hasCycled = self.CheckConfigurations(configuration: configuration);
            self.state.EndConfiguration()
        }
        return self.hasCycled
    }
    
    func CheckConfigurations(configuration: String) -> Bool {
        var exists: Bool = self.configurations.index(forKey: configuration) != nil
        if !exists {
            self.configurations[configuration] = self.total
        }
        return exists
    }
    
    func GetIndex() -> Int {
        var maxIndex: Int = 0
        var max: Int = self.products[maxIndex]
        for (index, value) in self.products.enumerated() {
            if max < value {
                max = value
                maxIndex = index
            }
        }
        return maxIndex
    }
    
    func Configuration() -> String {
        return self.products.flatMap({ String($0) }).joined(separator: COMMA_SEPARATOR)
    }
    
    func Execute() {
        while !self.CycleDetected() {
            var index: Int = self.GetIndex()
            self.Distribute(atIndex: index)
            self.total += 1
        }
        let cycledConfiguration: String = self.Configuration();
        let loopsBetween: Int = self.total - self.configurations[cycledConfiguration]!;
        
        print("Duplicate Configuration: \(cycledConfiguration)")
        print("Total Loops until Cycle: \(self.total)")
        print("Loops Between Repeated Cycle: \(loopsBetween)")
    }
}