#!/usr/local/bin/python3
from applib.helm import Helm
from applib.repo import Repo, RepoType
import sys, os, time, getopt, yaml
from common import *

TEMPDIR="tmp"

def printhelp():
  print(('''
check repositories from the given manifest

Usage: {0} -m manifest [-t target-repository-to-compare ][-v]
  -m    a resource manifest file to check (ex. ../../lma/base/resources.yaml )
  -r    the target repository to check (ex. https://openinfradev.github.io )
  -e    exception list for checking (ex. https://prometheus-community.github.io/helm-charts, https://prometheus-community.github.io/helm-charts,... )
  -t    type of checking ('chart' or 'image' )
  -v    verbos mode (it is same with --verbose=1)

Examples:
  - {0} -m ../../lma/base/resources.yaml -r https://taco.com/tks -v
''').format(sys.argv[0]))


def main(argv):
  target_repo='https://harbor-cicd.taco-cat.xyz/tks'
  manifest_file=''
  verbose=0
  except_list=[]
  check_type='chart'

  try:
    opts, args = getopt.getopt(argv,"hm:t:r:e:v")
  except getopt.GetoptError:
    printhelp()
    sys.exit(-1)

  for opt, arg in opts:
    if opt == '-h':
      printhelp()
      sys.exit(0)
    elif opt == "-m":
      manifest_file=arg
    elif opt == "-r":
      target_repo=arg
    elif opt == "-t":
      check_type=arg
    elif opt == "-e":
      except_list = arg.split(',')
    elif opt == "-v":
      verbose=1

  if (manifest_file==''):
    printhelp()
    sys.exit(-1)

  if check_type=='chart':
    invalides = check_chart_repo(open(manifest_file), target_repo, except_list, verbose)
  elif check_type=='image':
    invalides = check_image_repo(open(manifest_file), target_repo, except_list, verbose)
  else:
    print(f'type={check_type} is not supported yes!!')
    sys.exit(-1)

  if (len(invalides)>0):
    raise Exception( f'{len(invalides)} repositoy is defined with a invalid site.\n{invalides}')
  else:
    print('every repository is well defined')

if __name__ == "__main__":
  main(sys.argv[1:])
