open System.IO
open System
open System.Linq

type Vector(text:string) =    
    let input : string[] = text.Replace("<", "").Replace(">", "").Split('=')
    let values : string[] = input.[1].Split(',')

    let t = input.[0]
    let mutable x : float = values.[0] |> float 
    let mutable y : float = values.[1] |> float
    let mutable z : float = values.[2] |> float

    member val X = x with get, set
    member val Y = y with get, set
    member val Z = z with get, set
    member val T = t with get

    member this.Add(other : Vector) =
        this.X <- this.X + other.X
        this.Y <- this.Y + other.Y
        this.Z <- this.Z + other.Z
    
    member this.DistanceFromCenter() =
        Math.Sqrt(this.X * this.X + this.Y * this.Y + this.Z * this.Z)
    
    member this.Collide(other : Vector) =
        this.X = other.X && this.Y = other.Y && this.Z = other.Z

    override this.ToString() =
        String.Format("{0}=<{1},{2},{3}>", this.T, this.X, this.Y, this.Z)
    
type Particle(identifier:int, text:string) =
    let parts = text.Split([|", "|], StringSplitOptions.RemoveEmptyEntries)

    let mutable position : Vector = new Vector(parts.[0])
    let mutable velocity : Vector = new Vector(parts.[1])
    let mutable acceleration : Vector = new Vector(parts.[2])
    let id : int = identifier

    member val Id = id with get
    member val Position = position with get
    member val Velocity = velocity with get
    member val Acceleration = acceleration with get

    member this.Tick() =
        this.Velocity.Add(this.Acceleration)
        this.Position.Add(this.Velocity)
    
    member this.DistanceFromCenter() = this.Position.DistanceFromCenter()
    member this.VelocityFromCenter() = this.Acceleration.DistanceFromCenter()
    member this.AccelerationFromCenter() = this.Acceleration.DistanceFromCenter()
    member this.Collide(other : Particle) = this.Position.Collide(other.Position)

    override this.ToString() =
        String.Format("ID:{0} {1} {2} {3}", this.Id, this.Position.ToString(), this.Velocity.ToString(), this.Acceleration.ToString())



type Simulator(text:string) =
    let data = text.Split([| Environment.NewLine |], StringSplitOptions.RemoveEmptyEntries) 
    let mutable particles : List<Particle> = data |> Array.toList 
                                                  |> List.indexed 
                                                  |> List.map(fun (index, text) -> new Particle(index, text))
    
    member val Particles = particles with get, set

    member this.Tick() =
        this.RemoveCollisions()
        for particle in particles do particle.Tick()
    
    member this.RemoveCollisions() =
        let mutable collisions : List<Particle> = [for particle in this.Particles do for other in this.Particles do if particle <> other && particle.Collide(other) then yield particle]
        this.Particles <- Collections.List.ofSeq(this.Particles.Where(fun particle -> not(collisions.Contains(particle))))            

    override this.ToString() =
        String.Join(Environment.NewLine, particles)
      


// Learn more about F# at http://fsharp.org
// See the 'F# Tutorial' project for more help.

[<EntryPoint>]
let main argv =    
    let data = System.IO.File.ReadAllText "input.txt"
    
    let simulator = new Simulator(data)

    //sort by acceleration from center, then velocity (tie breaker for matching acceleration), then distance (tie breaker for matching velocity)
    let sorted = simulator.Particles |> List.sortBy (fun p -> p.AccelerationFromCenter(), p.VelocityFromCenter(), p.DistanceFromCenter())
    
    let part1 = String.Format("Closest Particle To Center: {0}", sorted.Head.ToString())
    System.Console.WriteLine(part1)

    //should really compute this rather than ticking X times
    [for _ in 0..50 do simulator.Tick()] |> ignore

    let part2 = String.Format("Particles Remaining: {0}", simulator.Particles.Count())
    System.Console.WriteLine(part2)
    //System.Console.WriteLine(simulator.ToString())
    //System.Console.WriteLine(simulator.ToString())
    printf "Press any key to continue..."
    //System.Console.ReadKey() |> ignore
    0 // return an integer exit code