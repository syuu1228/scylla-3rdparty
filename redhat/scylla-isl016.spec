Summary: Integer point manipulation library
Name: scylla-isl016
Version: 0.16.1
License: MIT
Group: System Environment/Libraries
URL: http://isl.gforge.inria.fr/

%global libmajor 15
%global libversion %{libmajor}.1.1

%define _prefix /opt/scylladb

# Please set buildid below when building a private version of this rpm to
# differentiate it from the stock rpm.
#
# % global buildid .local

Release: 1%{?buildid}%{?dist}

BuildRequires: gmp-devel
BuildRequires: pkgconfig
Requires: scylla-env

Source0: http://isl.gforge.inria.fr/isl-%{version}.tar.xz

%description
isl is a library for manipulating sets and relations of integer points
bounded by linear constraints.  Supported operations on sets include
intersection, union, set difference, emptiness check, convex hull,
(integer) affine hull, integer projection, computing the lexicographic
minimum using parametric integer programming, coalescing and parametric
vertex enumeration.  It also includes an ILP solver based on generalized
basis reduction, transitive closures on maps (which may encode infinite
graphs), dependence analysis and bounds on piecewise step-polynomials.

%package devel
Summary: Development for building integer point manipulation library
Requires: scylla-isl016%{?_isa} == %{version}-%{release}
Requires: gmp-devel%{?_isa}
Group: Development/Libraries

%description devel
isl is a library for manipulating sets and relations of integer points
bounded by linear constraints.  Supported operations on sets include
intersection, union, set difference, emptiness check, convex hull,
(integer) affine hull, integer projection, computing the lexicographic
minimum using parametric integer programming, coalescing and parametric
vertex enumeration.  It also includes an ILP solver based on generalized
basis reduction, transitive closures on maps (which may encode infinite
graphs), dependence analysis and bounds on piecewise step-polynomials.

%prep
%global docdir isl-%{version}
%setup -q -n isl -c

%build
cd isl-%{version}
%configure
make %{?_smp_mflags} V=1

%install
cd isl-%{version}
%make_install INSTALL="install -p"
rm -f %{buildroot}/%{_libdir}/libisl.a
rm -f %{buildroot}/%{_libdir}/libisl.la
mkdir -p %{buildroot}/%{_datadir}
%global gdbprettydir %{_datadir}/gdb/auto-load/%{_libdir}
mkdir -p %{buildroot}/%{gdbprettydir}
mv %{buildroot}/%{_libdir}/*-gdb.py* %{buildroot}/%{gdbprettydir}

%check
cd isl-%{version}
#make check

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%{_libdir}/libisl.so.%{libmajor}
%{_libdir}/libisl.so.%{libversion}
%{gdbprettydir}/*
%license %{docdir}/LICENSE
%doc %{docdir}/AUTHORS %{docdir}/ChangeLog %{docdir}/README

%files devel
%{_includedir}/*
%{_libdir}/libisl.so
%{_libdir}/pkgconfig/isl.pc
%doc %{docdir}/doc/manual.pdf


%changelog
* Thu Feb 02 2017 David Howells <dhowells@redhat.com> - 0.16.1-1
- Move to version 0.16.1.
- Build and install just the libraries from 0.14 so that gcc can work.

* Wed Feb 01 2017 Stephen Gallagher <sgallagh@redhat.com> - 0.14-6
- Add missing %%license macro (#1418512)

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 0.14-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.14-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Mon Jan 5 2015 David Howells <dhowells@redhat.com> - 0.14-3
- Initial packaging.
