//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>
#include <tuple>  // Include the tuple header

namespace host {
    std::tuple<std::vector<std::string>, std::vector<std::string>> get_sp();
}

//#endif // HOST_HPP