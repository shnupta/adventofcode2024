use core::panic;
use std::{collections::{HashMap}, env, fs::{self}};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Usage: ./main <inputfile>");
    }

    let filename = args.get(1).unwrap();
    let file_contents = fs::read_to_string(filename).unwrap();

    let mut left_vec: Vec<i64> = Vec::new();
    let mut right_map: HashMap<i64, i64> = HashMap::new();

    for line in file_contents.split('\n') {
        if line.is_empty() { break; }

        let mut split = line.split_whitespace();

        let left: i64 = split.next().unwrap().parse().unwrap();
        let right: i64 = split.next().unwrap().parse().unwrap();

        left_vec.push(left);

        let count = right_map.get(&right).unwrap_or(&0);
        right_map.insert(right, count + 1);
    }

    let mut similarity = 0;

    for left in left_vec.iter() {
        similarity += left * right_map.get(left).unwrap_or(&0);
    }

    println!("similarity = {}", similarity);
}
