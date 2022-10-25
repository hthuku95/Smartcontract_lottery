from .helpful_scripts import get_account
from brownie import Lottery
def deploy_lottery():
    account = get_account()

def main():
    deploy_lottery()