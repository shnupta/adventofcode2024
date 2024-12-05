use std::{collections::{HashMap, HashSet, VecDeque}, env, fs};

fn topo(p: i32, v: &mut HashSet<i32>, s: &mut VecDeque<i32>, g: &HashMap<i32, HashSet<i32>>, scope: &Vec<i32>) {
    v.insert(p);
    let page_orderings = g.get(&p);

    match page_orderings {
        Some(po) => {
            for n in po.iter() {
                if scope.contains(n) && !v.contains(n) {
                    topo(*n, v, s, g, scope);
                }
            }
        }
        _ => (),
    }

    s.push_back(p);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Usage: ./main <inputfile>");
    }

    let filename = args.get(1).unwrap();
    let binding = fs::read_to_string(filename).unwrap();
    let file_contents = binding.trim();

    let mut orderings: HashMap<i32, HashSet<i32>> = HashMap::new();
    let mut orderings_complete = false;

    let mut updates: Vec<Vec<i32>> = Vec::new();

    for line in file_contents.split('\n') {
        if line.is_empty() {
            orderings_complete = true;
            continue;
        }

        if orderings_complete {
            updates.push(line.split(',').map(|n| n.parse().unwrap()).collect());
        } else {
            let ordering: Vec<i32> = line.split('|').map(|s| s.parse().unwrap()).collect();
            assert!(ordering.len() == 2);

            let after: &mut HashSet<i32> = orderings.entry(ordering[0]).or_default();
            after.insert(ordering[1]);
        }
    }

    let mut incorrect_updates: Vec<Vec<i32>> = Vec::new();
    let mut sum: i32 = 0;
    'update_loop: for update in &updates {
        let mut seen: HashSet<i32> = HashSet::new();
        for page in update {
            let page_orderings = orderings.entry(*page).or_default();
            if !seen.is_disjoint(page_orderings) {
                incorrect_updates.push(update.to_vec());
                continue 'update_loop;
            }
            seen.insert(*page);
        }
        sum += update.get(update.len() / 2).unwrap();
    }

    println!("correct sum = {}", sum);

    let mut incorrect_sum: i32 = 0;

    incorrect_updates.iter().for_each(|update| {
        // println!("original = {:?}", update);
        // lets topo-sort this
        let mut stack: VecDeque<i32> = VecDeque::new();
        let mut visited: HashSet<i32> = HashSet::new();

        for page in update.iter() {
            if !visited.contains(page) {
                topo(*page, &mut visited, &mut stack, &orderings, update);
            }
        }

        let mut out: VecDeque<i32> = VecDeque::new();
        while !stack.is_empty() {
            out.push_back(stack.pop_back().unwrap());
        }

        incorrect_sum += out.get(out.len() / 2).unwrap();

        // println!("reordered = {:?}", out);
    });
    println!("incorrect sum = {}", incorrect_sum);
}
