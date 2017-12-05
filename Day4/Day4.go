package main

import (
    "os"
    "bufio"
    "log"
    "flag"
    "strings"
    "sort"
    "fmt"
)

const (
    Space = " "
    NewLine = "\n"
    Empty = ""
)

func main() {
    //declare/set the flags for the program, these can be seen by using --help in the command line
    filenamePtr := flag.String("file", "input.txt", "Specify a file to read input from")
    sortWordsPtr := flag.Bool("sort", false, "[For Part 2] Should each word in the passphrase be sorted?")
    
    //parse the flags
    flag.Parse()
    
    //attempt to open the file
    file, err := os.Open(*filenamePtr)
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()
    
    sortFn := getSortFunc(*sortWordsPtr)
    validPassphrases := 0
    
    //begin scanning the file for passphrases and process them, line by line
    passphraseScanner := bufio.NewScanner(file)
    for passphraseScanner.Scan() {
        passphrase := passphraseScanner.Text()
        if !containsDuplicateWord(passphrase, Space, sortFn) {
            validPassphrases++
        }
    }
    
    //did the scanner stop because of an error? If so, log it
    if err := passphraseScanner.Err(); err != nil {
        log.Fatal(err)
    }

    fmt.Printf("Total Valid Passphrases: %d", validPassphrases)
}


func containsDuplicateWord(passphrase, delimiter string, sortFn func(string) string) bool {
    words := strings.Split(passphrase, delimiter)
    //used to detect if a duplicate exists
    wordMap := make(map[string]int)
    for _, word := range words {
        //sort word with anonymous sort function
        sortedWord := sortFn(word)
        
        //check if word exists in dictionary already (if so, we have a duplicate)
        if _, ok := wordMap[sortedWord]; ok {
            return true
        }
        
        //otherwise, set the map index
        wordMap[sortedWord] = 1
    }
    return false
}

func getSortFunc(sortWords bool) func(string) string {
    if sortWords {
        return func(word string) string {
            //sort the string by splitting it into an array first, then joining it back together
            letters := strings.Split(word, Empty)
            sort.Strings(letters)
            return strings.Join(letters, Empty)
        }
    }
    //Default sort function, do nothing
    return func(word string) string {
        return word
    }
}

