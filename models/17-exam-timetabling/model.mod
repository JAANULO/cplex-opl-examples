// ==========================================
// 17-exam-timetabling/model.mod
// ==========================================

// Parameters defined inline
int numSlots = 3;
range Slots = 1..numSlots;

{string} Students = {"John", "Anna", "Peter"};
{string} Courses = {"Mathematics", "Physics", "Computer Science"};

// Data from external source
tuple Registration {
    string student;
    string course;
}
{Registration} registrations = ...;

// Conflict calculation (logic in tuple sets)
tuple Conflict {
    string c1;
    string c2;
}

{Conflict} conflicts = { <c1, c2> | 
    c1, c2 in Courses, s in Students : 
    c1 != c2 && 
    <s, c1> in registrations && 
    <s, c2> in registrations 
};

// ==========================================
// ASSERTIONS (Testing assert block)
// ==========================================
assert {
    // Each student must have at least one course
    forall(s in Students)
        sum(r in registrations: r.student == s) 1 >= 1;
        
    // Number of slots cannot be negative
    numSlots > 0;
}

// ==========================================
// MODEL
// ==========================================
dvar boolean x[Courses][Slots];

minimize sum(c in Courses, s in Slots) x[c][s];

subject to {
    // Each course must take place in exactly one slot
    forall(c in Courses)
        Assignment:
        sum(s in Slots) x[c][s] == 1;

    // Students cannot write 2 exams in the same slot
    forall(con in conflicts, s in Slots)
        Collision:
        x[con.c1][s] + x[con.c2][s] <= 1;
}

execute {
    writeln("Conflicts detected: ", conflicts.size);
}
