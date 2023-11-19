using StanIO, Test

sm = StaticSampleModel("arrays", "")

nt = StanIO.read_samples(sm, :namedtuple)
