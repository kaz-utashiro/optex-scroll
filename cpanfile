requires 'perl', '5.024';

requires 'App::optex', '1.00';
requires 'Term::ReadKey';
requires 'Term::ANSIColor::Concise';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

