/*Copyright 2019-2023 Kai D. Gonzalez*/

// learner - a learning algorithm for sequencial modeling

import std.random;
import std.stdio : writefln, File, remove;
import std.string : strip;
import std.file : exists;

struct Wrong
{
    string identifier; /* a way to know what was wrong */
}

Wrong initWrong(string identifier)
{
    Wrong w;
    w.identifier = identifier;
    return w;
}

/** 
 * a learner
 * saves the wrongs and learns not to repeat the same mistakes
 */
struct Learner
{
    Wrong[] wrongs;
    bool has_learned = false;
    int attempts = 0;
}

Learner initLearner()
{
    Learner l;
    l.wrongs = [];
    return l;
}

void addWrong(Learner* l, Wrong w)
{
    l.wrongs ~= (w);
}

void learn(Learner l, Wrong w)
{
    l.wrongs ~= (w);
}

void printWrong(Wrong w)
{
    writefln("Wrong: %s", w.identifier);
}

void exportWrongsToCSV(Learner l)
{
    auto exp = File("wrongs.csv", "w");

    for (int i = 0; i < l.wrongs.length; i++)
    {
        exp.writef("%s\n", l.wrongs[i].identifier);
        exp.flush();
    }

    exp.close();
}

void loadWrongsFromCSV(Learner* l)
{
    auto exp = File("wrongs.csv", "r");

    while (!exp.eof())
    {
        string identifier = strip(exp.readln());

        if (identifier != "")
        {
            l.wrongs ~= (initWrong(identifier));

        }

    }

    exp.close();

}

void printLearner(Learner l)
{
    for (int i = 0; i < l.wrongs.length; i++)
    {
        printWrong(l.wrongs[i]);
    }
}

bool learnerHasWrong(Learner* l, string identifier)
{
    for (int i = 0; i < l.wrongs.length; i++)
    {
        if (l.wrongs[i].identifier == identifier)
        {
            return true;
        }
    }
    return false;
}

void learnerExportRightAnswer(Learner* l, string right_answer)
{
    auto rightanswertxt = File("rightanswer.txt", "w");
    rightanswertxt.writef("%s", right_answer);
    rightanswertxt.close();
}

void learnerGuess(Learner* l, string[] answers, string right_answer)
{
    l.attempts++;
    auto guess_num = uniform(0, answers.length);

    string guess = answers[guess_num];

    if (exists("rightanswer.txt"))
    {
        auto rightanswertxt = File("rightanswer.txt", "r");
        guess = strip(rightanswertxt.readln());
        rightanswertxt.close();

        writefln("\x1b[37;3m[+] (rightanswer.txt) old right answer:\x1b[0m %s", guess);

        if (guess != right_answer)
        {
            writefln(
                "\x1b[90;3mai:\x1b[0m my knowledge is outdated, retrying and removing previous right answer");
            remove("rightanswer.txt");
        }
    }

    else if (learnerHasWrong(l, guess))
    {
        learnerGuess(l, answers, right_answer);
        return;
    }

    if (guess == right_answer)
    {
        writefln("\x1b[32;1m[+] correct!\x1b[0m");
        l.has_learned = true;
        learnerExportRightAnswer(l, guess);
        return;
    }
    else
    {
        if (strip(guess).length > 0)
        {
            addWrong(l, initWrong(guess));
        }
    }
}

void main()
{
    Learner l = initLearner();

    if (exists("wrongs.csv"))
    {
        loadWrongsFromCSV(&l);
    }

    auto n = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
    "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w",
    "x", "y", "z", "bug", "bug2", "bug3", "bug4", "bug5", "bug6",
    "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
    "iota", "kappa", "lambda",
    "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi",
    "chi",
    "psi", "omega", "element", "compound", "reaction", "molecule", "atom",
    "proton", "neutron", "electron",
    "quark", "photon", "neutrino", "protoplanet", "comet", "galaxy",
    "telescope",
    "microscope", "magnet", "circuit", "battery", "antenna", "satellite",
    "asteroid",
    "meteoroid", "cosmos", "blackhole", "wormhole", "supernova",
    "nebula", "constellation", "asterism", "telescope", "observatory",
    "cosmology", "gravitation", "inertia", "particle", "fusion", "nuclear",
    "radiation", "spectroscopy", "astrophysics", "dark matter", "exoplanet",
    "parallax", "telescope", "planetarium", "telemetry", "celestial", "eclipse",
    "astronomer", "cosmic", "universe", "stellar", "cosmonaut", "astronaut"
];


    while (!l.has_learned)
    {
        learnerGuess(&l, n, "cosmic");
    }

    exportWrongsToCSV(l);

    writefln("\x1b[32;3m[+] my knowledge is now up to date!\x1b[0m");
    writefln("\x1b[32;3m[+] attempts:\x1b[0m %d", l.attempts);
}
