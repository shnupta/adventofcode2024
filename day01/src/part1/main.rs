use core::panic;
use std::{collections::BinaryHeap, env, fs::{self}};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Usage: ./main <inputfile>");
    }

    let filename = args.get(1).unwrap();
    let file_contents = fs::read_to_string(filename).unwrap();

    let mut left_heap: BinaryHeap<i64> = BinaryHeap::new();
    let mut right_heap: BinaryHeap<i64> = BinaryHeap::new();

    for line in file_contents.split('\n') {
        if line.is_empty() { break; }

        let mut split = line.split_whitespace();

        let left: i64 = split.next().unwrap().parse().unwrap();
        let right: i64 = split.next().unwrap().parse().unwrap();

        left_heap.push(left);
        right_heap.push(right);
    }

    assert_eq!(left_heap.len(), right_heap.len());

    let mut distance: u64 = 0;
    while left_heap.len() > 0 && right_heap.len() > 0 {
        let left = left_heap.pop().unwrap();
        let right = right_heap.pop().unwrap();

        let diff = left.abs_diff(right);

        println!("{} {} dist = {}", left, right, diff);
        distance += Into::<u64>::into(diff);
    }

    print!("distance is {}", distance);
}
